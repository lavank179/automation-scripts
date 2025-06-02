import requests
import time
from concurrent.futures import ThreadPoolExecutor

class Downloader:
  def __init__(self, session=None):
    if session is not None:
      self.session = session

  def download(self, url, findex):
    start_time = time.time()
    res = self.session.get(url, stream=True, verify="<PATH_TO_SSL_KEY>")
    filepath = f"./downs/f{findex}.zip" # Create your own downs folder whereever your app is runnning or add create dir code above.
    try:
      if res.status_code == 200:
        with open(filepath, "wb") as f:
          for chunk in res.iter_content(chunk_size=10485760):
            f.write(chunk)
        print(f"Done file - {filepath} - timetaken:{get_elapsed_time(start_time)}")
      else:
        print(f"Error: {res.text} - timetaken:{get_elapsed_time(start_time)}")
    except Exception as e:
      print(f"Unexpected error: {e.args[0]}")

  def threadTester(self, work):
    start_time = time.time()
    time.sleep(5)
    print(f"{work} - timetaken:{get_elapsed_time(start_time)}")

urls = []
for i in range(3):
  urls.append("https://awscli.amazonaws.com/AWSCLIV2.msi")
for i in range(3):
  urls.append("https://dist.nuget.org/win-x86-commandline/latest/nuget.exe")

def get_elapsed_time(start_time):
  return float(time.time() - start_time)

session = requests.Session()
session.headers.update({
    "Authorization": f"token <YOUR_TOKEN_TO_ANY_SECURED_SITE>",
    "Accept": "application/vnd.github.v3+json"
})

download = Downloader(session)
# download = Downloader()
start_time = time.time()

# for index, url in enumerate(urls):
#   download.download(url, index)
with ThreadPoolExecutor(max_workers=5) as exe:
  for index, url in enumerate(urls):
    exe.submit(download.download, url, index)

# for i in range(5):
#   download.threadTester(i)
# with ThreadPoolExecutor(max_workers=5) as exe:
#   for i in range(5):
#     exe.submit(download.threadTester, i)
print(f"Total Timetaken: {get_elapsed_time(start_time)} seconds.")
