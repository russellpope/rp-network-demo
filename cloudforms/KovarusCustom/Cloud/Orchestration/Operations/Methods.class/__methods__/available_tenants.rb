#
# Description: provide the dynamic list content from available tenants
#
module ManageIQ
  module Automate
    module Cloud
      module Orchestration
        module Operations
          class AvailableTenants
            def initialize(handle = $evm)
              @handle = handle
            end

            def main
              fill_dialog_field(fetch_list_data)
            end

            def fetch_list_data
              os_provider = $evm.vmdb('ext_management_system').where(:type => "ManageIQ::Providers::Openstack::CloudManager")
              av_tenants = $evm.vmdb('cloud_tenant').where(:enabled => true, :ems_id => os_provider.first.id)

              tenant_list = { nil => "<default>" }
              av_tenants.each { |tenant| tenant_list[tenant.name] = tenant.name } if av_tenants

              tenant_list
            end

            def fill_dialog_field(list)
              dialog_field = @handle.object

              # sort_by: value / description / none
              dialog_field["sort_by"] = "description"

              # sort_order: ascending / descending
              dialog_field["sort_order"] = "ascending"

              # data_type: string / integer
              dialog_field["data_type"] = "string"

              # required: true / false
              dialog_field["required"] = "false"

              dialog_field["values"] = list
              dialog_field["default_value"] = nil
            end
          end
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  ManageIQ::Automate::Cloud::Orchestration::Operations::AvailableTenants.new.main
end