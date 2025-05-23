from flask import Flask, request, jsonify
from googleapiclient.discovery import build
from config import YOUTUBE_API_KEY
import pandas as pd

app = Flask(__name__)
youtube = build("youtube", "v3", developerKey=YOUTUBE_API_KEY)

data_store = []  # Global cache for demo purposes

def fetch_videos(query, max_results=100):
    videos = []
    next_page_token = None

    while len(videos) < max_results:
        remaining = max_results - len(videos)
        request = youtube.search().list(
            q=query,
            part="id,snippet",
            type="video",
            maxResults=min(50, remaining),
            pageToken=next_page_token
        )
        response = request.execute()

        for item in response.get("items", []):
            if (not item["id"]["kind"] == "youtube#video"):
                continue
            
            video_id = item.get("id", {}).get("videoId")
            if not video_id:
                continue
            try:
                stats = youtube.videos().list(
                    part="statistics,snippet",
                    id=video_id
                ).execute()

                for v in stats.get("items", []):
                    videos.append({
                        "title": v["snippet"]["title"],
                        "videoId": video_id,
                        "viewCount": int(v["statistics"].get("viewCount", 0)),
                        "likeCount": int(v["statistics"].get("likeCount", 0)),
                        "channelTitle": v["snippet"]["channelTitle"]
                    })
            except Exception as e:
                print(f"Error fetching stats for {video_id}: {e}")

        next_page_token = response.get("nextPageToken")
        if not next_page_token:
            break  # no more pages

    return videos

@app.route("/search")
def search():
    query = request.args.get("query")
    if not query:
        return jsonify({"error": "Missing query parameter"}), 400

    videos = fetch_videos(query)
    global data_store
    data_store = videos  # cache for later use
    return jsonify(videos)

@app.route("/sort")
def sort():
    key = request.args.get("by", "viewCount")
    reverse = request.args.get("order", "desc") == "desc"
    sorted_data = sorted(data_store, key=lambda x: x.get(key, 0), reverse=reverse)
    return jsonify(sorted_data)

@app.route("/nth")
def nth_highest():
    by = request.args.get("by", "viewCount")
    rank = int(request.args.get("rank", 1)) - 1
    sorted_data = sorted(data_store, key=lambda x: x.get(by, 0), reverse=True)
    if 0 <= rank < len(sorted_data):
        return jsonify(sorted_data[rank])
    return jsonify({"error": "Rank out of bounds"}), 400

@app.route("/most_common")
def most_common():
    by = request.args.get("by", "viewCount")
    df = pd.DataFrame(data_store)
    value_counts = df[by].value_counts()
    if not value_counts.empty:
        val = value_counts.idxmax()
        count = value_counts.max()
        return jsonify({"value": int(val), "count": int(count)})
    return jsonify({"error": "No data"}), 400

@app.route("/count_exact")
def count_exact():
    by = request.args.get("by", "viewCount")
    value = int(request.args.get("value", -1))
    count = sum(1 for item in data_store if item.get(by) == value)
    return jsonify({"value": value, "count": count})

@app.route("/count_prefix")
def count_prefix():
    by = request.args.get("by", "viewCount")
    prefix = request.args.get("prefix", "")
    filtered = [item for item in data_store if str(item.get(by)).startswith(prefix)]
    sorted_filtered = sorted(filtered, key=lambda x: x[by], reverse=True)
    return jsonify(sorted_filtered)

if __name__ == "__main__":
    app.run(debug=True)
