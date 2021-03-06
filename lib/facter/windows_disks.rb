Facter.add('disks') do
  confine :kernel => 'windows'

  require_relative '../puppet_x/disk_facts/underscore.rb'
  require 'json'
  setcode do
    kernelmajversion = Facter.value('kernelmajversion')
    next if kernelmajversion == '6.0' # Get-disk is not available on Windows Server 2008
    next if kernelmajversion == '6.1' # Get-disk is not available on Windows Server 2008 R2

    disks_hashes = JSON.parse(Facter::Core::Execution.exec("powershell.exe -Command \"Get-Disk | Select-Object * -ExcludeProperty CimClass,CimInstanceProperties,CimSystemProperties | ConvertTo-Json -Depth 100 -Compress\"")) rescue []
    disks_hashes_renamed = []
    out = {}

    # Make sure that we can handle only one disk
    disks_hashes = [disks_hashes] if disks_hashes.kind_of?(Hash)

    # Change camel case to unserscores
    disks_hashes.each do |disk|
      current_disk_renamed = {}
      disk.each do |key,value|
        current_disk_renamed[key.underscore] = value
      end
      disks_hashes_renamed << current_disk_renamed
    end

    # Make the disk number the key
    disks_hashes_renamed.each do |disk|
      out[disk['number']] = disk
    end

    out
  end
end
