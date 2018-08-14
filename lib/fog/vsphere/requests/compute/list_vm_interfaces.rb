module Fog
  module Compute
    class Vsphere
      class Real
  # => VirtualE1000(
  #addressType: "assigned",
  #backing: VirtualEthernetCardNetworkBackingInfo(
  #  deviceName: "VM Network",
  #  dynamicProperty: [],
  #  network: Network("network-163"),
  #  useAutoDetect: false
  #),
  #connectable: VirtualDeviceConnectInfo(
  #  allowGuestControl: true,
  #  connected: true,
  #  dynamicProperty: [],
  #  startConnected: true,
  #  status: "ok"
  #),
  #controllerKey: 100,
  #deviceInfo: Description(
  #  dynamicProperty: [],
  #  label: "Network adapter 1",
  #  summary: "VM Network"
  #),
  #dynamicProperty: [],
  #key: 4000,
  #macAddress: "00:50:56:a9:00:28",
  #unitNumber: 7,
  #
        def list_vm_interfaces(vm_id, datacenter = nil)
          get_raw_interfaces(vm_id, datacenter).map {|nic| raw_to_hash nic}
        end

        def get_vm_interface(vm_id, options={})
          raw = get_raw_interface(vm_id, options)
          if raw
            raw_to_hash(raw)
          else
            nil
          end
        end
        
        def get_raw_interfaces(vm_id, datacenter = nil)
          get_vm_ref(vm_id, datacenter).config.hardware.device.grep(RbVmomi::VIM::VirtualEthernetCard)
        end
        
        def get_raw_interface(vm_id, options={})
          raise ArgumentError, "instance id is a required parameter" unless vm_id
          if options.is_a? Fog::Compute::Vsphere::Interface
            options
          else
            raise ArgumentError, "Either key or name is a required parameter. options: #{options}" unless options.key? :key or options.key? :mac or options.key? :name
            get_raw_interfaces(vm_id).find do |nic|
              (options.key? :key and nic.key==options[:key].to_i) or
              (options.key? :mac and nic.macAddress==options[:mac]) or
              (options.key? :name and nic.deviceInfo.label==options[:name])
            end
          end
        end
        
        private
        
        def raw_to_hash(nic)
          {
            :name    => nic.deviceInfo.label,
            :mac     => nic.macAddress,
	    :network => nic.backing.respond_to?("network") ? nic.backing.network.name : (nic.backing.respond_to?("port") ? nic.backing.port.portgroupKey : nic.backing),
            :status  => nic.connectable.status,
            :summary => nic.deviceInfo.summary,
            :type    => nic.class,
            :key     => nic.key,
          }
        end
        
      end
      
      class Mock
        def list_vm_interfaces(vm_id)
        end
      end
    end
  end
end
