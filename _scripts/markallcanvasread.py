# Using Canvas v1 API to access an Announcement and mark it as read

import json
import requests
import os
import datetime
import time
    
TOKEN = "1016~crBxrfaCBHMZwQCzN4XVchZz8QG3yGZQAxLzA7MmzMDvMXHJXnYMvTWe4aUGGWKA"
auth = {"Authorization": "Bearer " + TOKEN}
MY_DOMAIN = "https://ufl.instructure.com"

start_date = datetime.datetime(1000,1,1).isoformat() # Necessary to list all announcements


# Get all courses
courses = requests.get(MY_DOMAIN + "/api/v1/courses", headers=auth)


def mark_announcement_read(course_id, disc_id):    
    conn_str = MY_DOMAIN + "/api/v1/courses/" + str(course_id) + "/discussion_topics/" + str(disc_id) + "/read.json"
    requests.put(conn_str, headers={**auth, **{"Content-Length": "0"}})


for course in courses.json():
    course_id = course["id"]
    
    nowtime = datetime.datetime.now().isoformat()
    # Retrieve all announcements that have been published in the course:
    params = {"context_codes[]": "course_" + str(course_id), "start_date": start_date, "end_date": nowtime}
    announcements = requests.get(MY_DOMAIN + "/api/v1/announcements", headers=auth, params=params)
    
    for announcement in announcements.json():
        # Delete the offending announcements
        if announcement["read_state"] == "unread":
            disc_id = announcement["id"]
            # print(announcement["title"])
            # Mark the offending announcement as read
            mark_announcement_read(course_id, disc_id)
            print("Marked " + announcement["title"] + " as read.")
            time.sleep(1)
print("Done.")
