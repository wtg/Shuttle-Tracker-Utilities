from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
import cryptography.hazmat.primitives.serialization
import json
import requests
import uuid
import datetime
import base64

start = datetime.datetime.now()
end = start + datetime.timedelta(days=7)
id = uuid.uuid4()

keypath = input("Enter the path to the private key: ").strip()
inFile = open(keypath, "rb")
privateKeyFile = inFile.read()
inFile.close()
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

announcementDict = {"body":body, "subject":subject, "start":start, "end":end, "scheduleType":scheduleType, "id":str(id)}

#converting file to private key object
privateKey = cryptography.hazmat.primitives.serialization.load_ssh_private_key(privateKeyFile, None)
#print(privateKey)

# posts announcements information to server
def submitAnnouncement(announcementDict):
    concat = bytes(announcementDict["subject"] + announcementDict["body"], 'utf-8')
    signedKey = privateKey.sign(concat)
    #print(signedKey)
    signature = base64.b64encode(signedKey).decode()
    #print(signature)
    announcementDict["signature"] = signature
    r = requests.post("https://shuttletracker.app/announcements", data=json.dumps(announcementDict))
    # checks whether signature has been successfully read
    if (r.status_code == 403):
        print("Error Code 403: Signature was rejected, try another signing key.\n")
    elif (r.status_code == 200):
        print("Submission has been accepted.")
    else:
        print(f"Error code {r.status_code}: Aborted due to some unexpected error.")
    return

submitAnnouncement(announcementDict)