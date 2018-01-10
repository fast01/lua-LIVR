
# LIVR

---

# Reference

## Class functions & members

#### new( livr_rules [, is_auto_trim] )


#### register_default_rules( rules )


#### register_aliased_default_rule( alias )


#### default_rules


#### default_auto_trim



## Instance methods

#### validate( input )


#### register_rules( rules )


#### register_aliased_rule( alias )


#### get_rules()


# Examples

```lua
local livr = require 'LIVR/Validator'

-- Common usage
livr.default_auto_trim = true

local validator = livr.new{
    name      = 'required',
    email     = { 'required', 'email' },
    gender    = { one_of = { 'male', 'female' } },
    phone     = { max_length = 10 },
    password  = { 'required', { min_length = 10} },
    password2 = { equal_to_field = 'password' }
}

local valid_data, errors = validator:validate(user_data)
if valid_data then
    save_user(valid_data)
end

-- You can use modifiers separately or can combine them with validation:
local validator = livr.new{
    email = { 'required', 'trim', 'email', 'to_lc' }
}

-- Feel free to register your own rules
-- You can use aliases(preferable, syntax covered by the specification) for a lot of cases:

local validator = livr.new{
    password = { 'required', 'strong_password' }
}

validator:register_aliased_rule{
    name  = 'strong_password',
    rules = { min_length = 6 },
    error = 'WEAK_PASSWORD'
}

-- or you can write more sophisticated rules directly

local validator = livr.new{
    password = { 'required', 'strong_password' }
}

validator:register_rules{
    strong_password = function ()
        return function (value)
            if value ~= nil and value ~= '' then
                if type(value) ~= 'string' then
                    return value, 'FORMAT_ERROR'
                end
                if #value < 6 then
                    return value, 'WEAK_PASSWORD'
                end
            end
            return value
        end
    end
}
```

