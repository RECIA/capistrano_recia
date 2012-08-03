##
# Include Nagios Query Helper to Capistrano::Configuration
# in order to access helper from methods.
##
Capistrano::Configuration.class_eval do
  include Nagios::MkLiveStatus::QueryHelper
end

##
# override the actions invocation class of capistrano
# to add the run_parent method and give access to it inside task definition
##
Capistrano::Configuration::Actions::Invocation.class_eval do
  
  ##
  # Calculate the parent server of those in parameters and execute the command on them.
  # We can loop through the child by using:
  #  - $PARENT:GUEST$ : required if we loop through guests, its replaced by the child name of the host.
  #  - $PARENT:LOOP:START$ : (opt.) start of the loop if not defined its automatically positionned at the beginning of the command
  #  - $PARENT:LOOP:END$ : (opt.) end of the loop if not defined its automatically positionned at the end of the command
  def run_parent(cmd, options={}, &block)
    
    block ||= self.class.default_io_proc
    
    guest_servers = find_servers_for_task(current_task)
    hosts = Hash.new
    
    # redistribution des machines par hôte
    guest_servers.each do |server|
      guest = server.to_s
      mklive = Nagios::MkLiveStatus::Request.new(fetch(:nagios_path, nil))
      query = Nagios::MkLiveStatus::Query.new()
      query.get "hosts"
      query.addColumn "parents"
      query.addFilter nagmk_filter("host_name", "=", guest)

      result = mklive.query(query)
      
      parent = result.split("\n")[0] if result != nil

      if parent == nil or parent.empty? or parent.match(/^rca/)
        logger.important "Ce serveur (#{guest}) n'est pas une machine virtuelle : Aucun serveur hote trouve pour la machine"
      else
        if not hosts.key?(parent)
          hosts[parent] = Array.new
        end
        hosts[parent].push(guest)
      end

    end

    # save parent hosts as the callee
    ENV['HOSTS'] = hosts.keys.join(',')
    
    # create a command script.
    cmd = Capistrano::Command::Script.new("#{cmd.gsub(/\\/, '\\').gsub(/\"/,'\"')}") if cmd.kind_of? String
    cmd['host'] = hosts
    
    ## replace vars if they are encountered
    loop_start = "<% prop('host', Hash.new)['$CAPISTRANO:HOST$'].each do |guest| %>"
    loop_end = "<% end %>"
    loop_guest = "<%= guest %>"
    
    if cmd.include? "$PARENT:GUEST$"
      cmd.contents.insert(0, "$PARENT:LOOP:START$\n") if not cmd.include? "$PARENT:LOOP:START"
      cmd.contents.insert(-1, "\n$PARENT:LOOP:END$") if not cmd.include? "$PARENT:LOOP:END"
    end
      
    cmd.gsub(/\$PARENT:LOOP:START\$/, loop_start)
    cmd.gsub(/\$PARENT:LOOP:END\$/, loop_end)
    cmd.gsub(/\$PARENT:GUEST\$/, loop_guest)
    
    # execute action.
    tree = Capistrano::Command::Tree.new(self) { |t| t.else(cmd, &block) }
    run_tree(tree, options)
  end
end