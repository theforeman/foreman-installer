# set capsule to have puppet by default
answers['capsule'] = { 'puppet' => true } unless answers['capsule'].is_a? Hash
