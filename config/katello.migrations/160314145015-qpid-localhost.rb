# Added to solve #11737 - qpid now only listens on localhost
answers['capsule']['qpid_router_broker_addr'] = 'localhost' if answers['capsule'].is_a? Hash
