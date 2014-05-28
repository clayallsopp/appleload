require 'shellwords'

require_relative 'appleload/version'
require_relative 'appleload/applescript'

class AppleLoad
  include AppleLoad::AppleScript

  LOCATION = "/Applications/Xcode.app/Contents/Applications/Application Loader.app"
  IOS_SUFFIX = " (iOS App)"

  def self.list
    new.list
  end

  def self.upload(*args)
    new.upload(*args)
  end

  def initialize
    enable_accessibility!
  end

  def enable_accessibility!
    # see https://gist.github.com/lacostej/3868129
    `sudo sh -c "/bin/echo -n \"a\" > /private/var/db/.AccessibilityAPIEnabled"`
    `sudo chmod 444 /private/var/db/.AccessibilityAPIEnabled`

    # see http://apple.stackexchange.com/a/122405
    ["/Applications/iTerm.app", "/Applications/Utilities/Terminal.app"].each do |app|
      bundle_id = `/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' #{app}/Contents/Info.plist`.strip
      sql_cmd = %Q{sudo sqlite3 '/Library/Application Support/com.apple.TCC/TCC.db' "INSERT OR REPLACE INTO access VALUES('kTCCServiceAccessibility','#{bundle_id}',0,1,1,NULL);" }
      `#{sql_cmd}`
    end
  end

  def with_gui(&block)
    open_app!
    begin
      result = yield
      quit_app!
      result
    rescue Exception => e
      quit_app!
      raise e
    end
  end

  def open_app!
    `open -a #{LOCATION.shellescape}`
    sleep 2
  end

  def quit_app!
    applescript('tell application "Application Loader" to quit')
    sleep 2
  end

  def open_delivery
    applescript %Q{
tell application "System Events"
  activate
  tell process "Application Loader"
    tell radio group 1 of window 1
      click button "Deliver Your App"
      delay 3
    end tell
  end tell
end tell}
    sleep 2
  end

  def list
    with_gui do
      self.open_delivery
      titles = applescript(%Q{
set menuItemTitles to ""
activate application "Application Loader"
tell application "System Events"
  tell process "Application Loader"
    tell window 1
      tell pop up button 1
        delay 1
        key code 49 # space bar
        delay 1
        count menu items of menu 1
        set menuItemTitles to name of menu items of menu 1
      end tell
    end tell
  end tell
end tell

return menuItemTitles
    }).gsub("Choose..., ", "").split(", ").map(&:strip).map { |string|
        without_suffix = string.split(IOS_SUFFIX).first
        version = without_suffix.split(" ")[-1]
        title = without_suffix.split(" ")[0..-1].join(" ")

        {
          title: title,
          version: version,
          type: :ios
        }
      }
    end
  end

  def upload(title, ipa_path)
    title = title[0..25] # only first 25 chars
    with_gui do
      self.open_delivery
      applescript(%Q{
set menuItemTitles to ""
set menuItemToSelect to "#{title}"
set ipaPath to "#{ipa_path}"

activate application "Application Loader"
tell application "System Events"
  tell process "Application Loader"
    tell window 1

      tell pop up button 1
        delay 1
        key code 49 # space bar
        delay 1
        click (menu item 1 where its name starts with menuItemToSelect) of menu 1
        delay 1
      end tell

      click button "Next"
      delay 1
      click button "Choose..."

      tell application "System Events"
        keystroke "g" using {shift down, command down}
        keystroke ipaPath
        delay 3
        keystroke return
        delay 3
        keystroke return
      end tell

      delay 2
      click button "Send"

      repeat until exists button "Next"
        delay 1
      end repeat
      click button "Next"
      repeat until exists button "Done"
        delay 1
      end repeat
      click button "Done"

    end tell
  end tell
end tell
})
      true
    end
  end
end