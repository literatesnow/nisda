# Reads variables from the environment.
class Env
  def initialize(key, required = true, default = nil)
    @key      = key
    @value    = ENV[key] || ''
    @default  = default  || ''
    @required = required
  end

  def to_s
    @value = @default if @value.empty?
    raise ArgumentError,
          "Missing env var: #{@key}", caller if @required && @value.empty?
    @value
  end

  def to_uri
    to_s.chomp '/'
  end
end
