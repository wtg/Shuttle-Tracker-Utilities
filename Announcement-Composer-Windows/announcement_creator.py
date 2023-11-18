from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
import cryptography.hazmat.primitives.serialization
import json
import requests
import uuid
import datetime
import base64
import os
import argparse

start = datetime.datetime.now()
end = start + datetime.timedelta(days=7)
id = uuid.uuid4()
serverChoice = input("Do you want to post the announcement to the staging or production server? [s/p] ")
parser = argparse.ArgumentParser()
parser.add_argument("-k", 
                    "--key_path",                 
                    help = "File path where users\'s private key is stored"
)
args = parser.parse_args()
keyPath = args.key_path
generateKey = False
if (keyPath is None):
    userChoice = input("Do you want to generate a key? [y/n]")
    if (userChoice.lower() in ["y", "yes"]):
        generateKey = True

if(generateKey == True):
    newPrivateKey = Ed25519PrivateKey.generate()
    privatePEM = newPrivateKey.private_bytes(
        encoding=cryptography.hazmat.primitives.serialization.Encoding.PEM,
        format=cryptography.hazmat.primitives.serialization.PrivateFormat.OpenSSH,
        encryption_algorithm=cryptography.hazmat.primitives.serialization.NoEncryption()    
    )
    folderpath = os.path.expanduser("~/Documents/STKeys")
    keyPath = os.path.join(folderpath, "STprivatekey.pem")
    if not os.path.exists(folderpath):
        os.makedirs(folderpath)
    with open(keyPath, "wb") as private_key_file:
        private_key_file.write(privatePEM)

inFile = open(keyPath, "rb")
privateKeyFile = inFile.read()
inFile.close()

passphrase = input("Enter Password. If none, enter 'n'").strip()

subject = input("Enter the subject:\n").strip()
body = input("Enter the body:\n").strip()

while True:
    try:
        scheduleType = input("Enter the schedule type(startOnly, endOnly, startAndEnd): ").strip()
        if(scheduleType == "startOnly" or scheduleType == "startAndEnd"):
            startstr = input("Enter Start Date(year-month-day-hour-minute): ")
            startarr = startstr.split("-")
            start = datetime.datetime(int(startarr[0]), int(startarr[1]), int(startarr[2]), int(startarr[3]), int(startarr[4]), 00)
            break
        elif(scheduleType == "endOnly" or scheduleType == "startAndEnd"):
            endstr = input("Enter End Date(year-month-day-hour-minute): ")
            endarr = endstr.split("-")
            end = datetime.datetime(int(endarr[0]), int(endarr[1]), int(endarr[2]), int(endarr[3]), int(endarr[4]), 00)
            break
        raise Exception(f"Unknown Schedule Type entered: {scheduleType}")
    except Exception as e:
        print("Error: ", e)

#convert time to acceptable format
start = start.replace(microsecond=00)
end = end.replace(microsecond=00)
start = start.isoformat() + "Z"
end = end.isoformat() + "Z"

while True:
    try:
        interruptionLevel = input("Enter the interruption level(passive, active, timeSensitive, critical): ").strip()
        if(interruptionLevel != "passive" and interruptionLevel != "active" and interruptionLevel != "timeSensitive" and interruptionLevel != "critical"):
            raise Exception(f"Unknown Interruption Level entered: {interruptionLevel}")
        break
    except Exception as e:
        print("Error: ", e)

announcementDict = {"scheduleType":scheduleType,"subject":subject,"end":end,"interruptionLevel":interruptionLevel,"body":body,"start":start,"id":str(id)}

#converting file to private key object
if(passphrase == 'n'):
    print("running")
    privateKey = cryptography.hazmat.primitives.serialization.load_ssh_private_key(privateKeyFile, None)
else:
    passphrase = bytes(passphrase,'utf-8')
    print(passphrase)
    privateKey = cryptography.hazmat.primitives.serialization.load_ssh_private_key(privateKeyFile, passphrase)

# posts announcements information to server
def submitAnnouncement(announcementDict, server):
    concat = bytes(announcementDict["subject"] + announcementDict["body"], 'utf-8')
    signedKey = privateKey.sign(concat)
    signature = base64.b64encode(signedKey).decode()
    announcementDict["signature"] = signature
    r = None
    if (serverChoice in ["s", "staging"]):
        r = requests.post("https://staging.shuttletracker.app/announcements", data=json.dumps(announcementDict))
    elif (serverChoice in ["p", "production"]):
        r = requests.post("https://shuttletracker.app/announcements", data=json.dumps(announcementDict))
    if (r.status_code == 403):
        print("Error Code 403: Signature was rejected, try another signing key.\n")
    elif (r.status_code == 200):
        print("Submission has been accepted.")
    else:
        print(f"Error code {r.status_code}: Aborted due to some unexpected error.")
    return

submitAnnouncement(announcementDict, serverChoice)