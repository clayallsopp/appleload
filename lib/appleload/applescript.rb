class AppleLoad
  module AppleScript
    def applescript(script)
      script = "osascript -e '#{script}'"
      result = `#{script}`
      if $?.to_i != 0
        raise "AppleScript Error"
      end
      result
    end
  end
end