#
# Description: This method prepares arguments and parameters for a job template
#
module ManageIQ
  module Automate
    module AutomationManagement
      module AnsibleTower
        module Service
          module Provisioning
            module StateMachines
              module Provision
                class Preprovision
                  def initialize(handle = $evm)
                    @handle = handle
                  end

                  def main
                    @handle.log("info", "Starting Ansible Tower Pre-Provisioning")
                    examine_request(service)
                    modify_job_options(service)
                  end

                  def task
                    @handle.root["service_template_provision_task"].tap do |task|
                      raise "service_template_provision_task not found" unless task
                    end
                  end

                  def service
                    task.destination.tap do |service|
                      raise "service is not of type AnsibleTower" unless service.respond_to?(:job_template)
                    end
                  end

                  # Through service you can examine the job template, configuration manager (i.e., provider)
                  # and options to start a job
                  def examine_request(service)
                    @handle.log("info", "manager = #{service.configuration_manager.name}")
                    @handle.log("info", "template = #{service.job_template.name}")

                    # Caution: job options may contain passwords.
                    # @handle.log("info", "job options = #{service.job_options.inspect}")
                  end

                  # You can also override job options through service
                  def modify_job_options(service)
                    # Example how to programmatically modify job options:
                    job_options = service.job_options
                    limit_names = prior_service_vm_names
                    job_options[:limit] = limit_names.join(",") unless limit_names.empty?
                    # job_options[:extra_vars]['flavor'] = 'm1.small'

                    # Important: set stack_options
                    service.job_options = job_options
                  end
                  
                  def prior_service_vm_names
                    vm_names = []
                    unless task.provision_priority.zero?
                      prior_task = task.miq_request_task.miq_request_tasks.find do |miq_request_task|
                        miq_request_task.provision_priority == task.provision_priority - 1
                      end
                      unless prior_task.nil?
                        prior_task.miq_request_tasks.each do |child_task|
                          child_task.miq_request_tasks.each do |grandchild_task|
                            vm_names << grandchild_task.get_option(:vm_target_name)
                          end
                        end
                      end
                    end
                    vm_names
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
if __FILE__ == $PROGRAM_NAME
  ManageIQ::Automate::AutomationManagement::AnsibleTower::Service::Provisioning::StateMachines::Provision::Preprovision.new.main
end
