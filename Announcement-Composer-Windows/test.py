from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
import json
import requests
import uuid
import datetime

start = datetime.datetime.now()
end = start + datetime.timedelta(days=7)
keypath = input("Enter the path to the private key: ").strip()
subject = input("Enter the subject: ").strip()
body = input("Enter the body: ").strip()
scheduleType = input("Enter the schedule type(startOnly, endOnly, startAndEnd): ").strip()
if(scheduleType == "s" or scheduleType == "b"):
    startstr = input("Enter Start Date(year-month-day-hour-minute): ")
    startarr = startstr.split("-")
    start = datetime.datetime(int(startarr[0]), int(startarr[1]), int(startarr[2]), int(startarr[3]), int(startarr[4]), 00)
if(scheduleType == "e" or scheduleType == "b"):
    endstr = input("Enter End Date(year-month-day-hour-minute): ")
    endarr = endstr.split("-")
    end = datetime.datetime(int(endarr[0]), int(endarr[1]), int(endarr[2]), int(endarr[3]), int(endarr[4]), 00)
start = start.isoformat() + "Z"
end = end.isoformat() + "Z"
interuptionLevel = input("Enter the interruption level(p for passive, a for active, t for timesensitive, c for critical): ").strip()
id = uuid.uuid4()
announcementDict = {"body":body, "subject":subject, "start":start, "end":end, "scheduleType":scheduleType, "id":id}

def submitAnnouncement():
    return