import os, datetime, re, sys, json

def schedule_shutdown(config):
	# Get current time and calculate delta time
	time_now = datetime.datetime.now()
	friday = 4
	saturday_or_sunday = 6 if config.get("schedule_shutdown_on_sundays") else 5
	if (time_now.weekday() >= friday 
	 or time_now.weekday() <= saturday_or_sunday): 
		#return # Skip weekends
		pass

	time_of_shutdown = datetime.datetime.strptime(config.get("time_of_shutdown"), "%H:%M")
	delta_hour = time_of_shutdown.hour - time_now.hour
	delta_minute = time_of_shutdown.minute - time_now.minute

	seconds_to_shutdown = delta_hour * 3600 + delta_minute * 60

	if (seconds_to_shutdown < 0):
		seconds_to_shutdown += 24 * 3600 # Add 24 hours if past shutdown time

	# Schedule shutdown
	print(f"Scheduling shutdown in {delta_hour} hours and {delta_minute} minutes")
	os.system(f"shutdown -s -t {seconds_to_shutdown}")
	input()

def setup():
	print("Enter desired time to shutdown (HH:MM)")
	s_time_of_shutdown = input("> ")

	# QoL, allow e.g. "23" to be parsed as "23:00"
	if (re.match(r"^\d{2}$", s_time_of_shutdown)):
		s_time_of_shutdown += ":00"
	if not re.match(r"^\d{2}:\d{2}$", s_time_of_shutdown):
		print("Invalid time format. Please use (HH:MM)")
		return
	
	print("Shutdown time set to " + s_time_of_shutdown, end="\n\n")

	print("Schedule shutdown on sundays? (y/n)")
	s_schedule_shutdown_on_sundays = input("> ").lower()

	# Write to file
	with open("shutdown_config.json", "w") as f:
		f.write(json.dumps({
			"time_of_shutdown": s_time_of_shutdown,
			"schedule_shutdown_on_sundays": s_schedule_shutdown_on_sundays == "y"
			}))
	
	# Create runner bat file
	dir_path = os.path.dirname(os.path.realpath(__file__))
	script = f"@echo off\n{dir_path}/bin/python.exe {dir_path}/main.py {dir_path}/shutdown_config.json"
	with open("shutdownScheduler.bat", "w") as f:
		f.write(script)

	print("Created 'shutdownScheduler.bat")
	print("Move this file to your startup folder now? (y/n)")
	if input("> ").lower() == "y":
		os.system(f"mv shutdownScheduler.bat \"%appdata%/Microsoft/Windows/Start Menu/Programs/Startup\"")

	print()
	print("Edit anytime by running setup again, or editing shutdown_config.json.")


def main():
	if len(sys.argv) < 1:
		print("Usage: python main.py setup")
	if sys.argv[1] == "setup":

		# Ask if user wants to overwrite existing config
		if not os.path.exists("shutdown_config.json"):
			setup()
		else:
			print("Config already exists. Overwrite? (y/n)")
			if input("> ").lower() == "y":
				setup()

	elif not os.path.exists(sys.argv[1]):
		print("Config file does not exist. Run setup first.")
		return
	else:
		
		with open(sys.argv[1], "r") as f:
			s_time_of_shutdown = f.read()
		config = json.loads(s_time_of_shutdown)
		schedule_shutdown(config)

	print()
	input("Press enter to close this window...")


if __name__ == "__main__":
	main()