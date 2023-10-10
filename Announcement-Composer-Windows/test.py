from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
import json
import requests
import uuid

subject = input("Enter the subject: ").strip()
body = input("Enter the body: ").strip()
scheduleType = input("Enter the schedule type(n for none, s for startonly, e for endonly, b for startAndEnd)").strip()
interuptionLevel = input("Enter the interruption level(p for passive, a for active, t for timesensitive, c for critical)").strip()
id = uuid.uuid4()
#add signature variable
#get private key
announcementDict = {"body":body, "subject":subject, "start":""}

def submitAnnouncement():
