webqq = {}

function webqq.create(self)
    local ret = {}
    ret.login = self.login
    return ret
end

function webqq.login(self)
    print('Logging in')
end
