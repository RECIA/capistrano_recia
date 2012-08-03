##
# override the actions invocation class of capistrano
# to add the run_parent method and give access to it inside task definition
##
Capistrano::Configuration::Actions::Invocation.class_eval do
  
  ##
  # Check if host contains task
  ##
  def host_as_task_role(current_host)
    # Active From debug Only !
    # puts "DEBUG :: #{current_host}"

    roles_ok_from_host = nil

    current_task.options[:roles].each do |task_role|
      
        # Active From debug Only !
        # puts "DEBUG :: #{task_role.to_s} ::"
        roles[:"#{task_role.to_s}"].servers.each do |server|
            # Active From debug Only !
            # puts "#{server}"
            if server.host.to_s == current_host.to_s
              roles_ok_from_host = 1
            end
        end
    end
    if roles_ok_from_host != nil && roles_ok_from_host != 0
        return 1
    else
        return 0
    end
  end
  
  ##
  # Use the role task option to filter the server with this role
  ##
  def run_filter_roles(cmd, options={}, &block)
    
    block ||= self.class.default_io_proc
    
    hosts_server = find_servers_for_task(current_task)
    hosts = Array.new
    
    ## calcul des rôles de la tâche
    if current_task.options[:roles].kind_of? Array
      current_task.options[:roles].each do |task_role|
        task_roles = "#{task_roles} #{task_role}"
      end
    else
      task_roles = "#{current_task.options[:roles]}"
      current_task.options[:roles] = [current_task.options[:roles]]
    end
    
    # redistribution des machines par hôte
    hosts_server.each do |server|
      if host_as_task_role(server).to_i == 0
        logger.info "Ce Serveur (#{server}) n'a pas un des role de la tache :#{task_roles}"
      else
        hosts.push(server.to_s)
      end
    end
    
    if hosts != nil and not hosts.empty?

      # save remaining hosts as the callee
      ENV['HOSTS'] = hosts.join(',')
    
      # execute action.
      tree = Capistrano::Command::Tree.new(self) { |t| t.else(cmd, &block) }
      run_tree(tree, options)
    else
      logger.important "Aucun serveurs ne possede un role : #{task_roles}"
    end
  end
  
  ##
  # Use the role task option to filter the server with this role and run a telnet method
  ##
  def run_telnet_filter_roles(cmd, options={}, &block)
    
    set(:telnet, "true")
    options[:shell] = false
    
    run_filter_roles(cmd, options, &block)
    
    unset(:telnet)
    
  end
  
end