from flask import Flask, request, jsonify
from googleapiclient.discovery import build
from config import YOUTUBE_API_KEY
import pandas as pd
import heapq

app = Flask(__name__)
youtube = build("youtube", "v3", developerKey=YOUTUBE_API_KEY)

data_store = []
field_counter = {}
field_trie = {}

class TrieNode:
    def __init__(self):
        self.children = {}
        self.items = []

class Trie:
    def __init__(self):
        self.root = TrieNode()

    def insert(self, key: str, item: dict):
        node = self.root
        for ch in key:
            if ch not in node.children:
                node.children[ch] = TrieNode()
            node = node.children[ch]
            node.items.append(item)

    def search_prefix(self, prefix: str):
        node = self.root
        for ch in prefix:
            if ch not in node.children:
                return []
            node = node.children[ch]
        return node.items


def build_indexes():
    global field_counter, field_trie
    field_counter = {}
    field_trie = {}

    for item in data_store:
        for key, val in item.items():
            # build counter
            if key not in field_counter:
                field_counter[key] = {}
            field_counter[key][val] = field_counter[key].get(val, 0) + 1

            # build trie only for str-able fields
            str_val = str(val)
            if key not in field_trie:
                field_trie[key] = Trie()
            field_trie[key].insert(str_val, item)


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
            if item["id"]["kind"] != "youtube#video":
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
            break

    return videos


@app.route("/search")
def search():
    query = request.args.get("query")
    if not query:
        return jsonify({"error": "Missing query parameter"}), 400

    global data_store
    data_store = fetch_videos(query)
    build_indexes()
    return jsonify(data_store)


@app.route("/sort")
def sort():
    key = request.args.get("by", "viewCount")
    reverse = request.args.get("order", "desc") == "desc"
    sorted_data = sorted(data_store, key=lambda x: x.get(key, 0), reverse=reverse)
    return jsonify(sorted_data)


@app.route("/nth")
def nth_highest():
    by = request.args.get("by", "viewCount")
    rank = int(request.args.get("rank", 1))

    if rank <= 0 or not data_store:
        return jsonify({"error": "Invalid rank"}), 400

    try:
        top_n = heapq.nlargest(rank, data_store, key=lambda x: x.get(by, 0))
        return jsonify(top_n[-1])
    except IndexError:
        return jsonify({"error": "Rank out of bounds"}), 400


@app.route("/most_common")
def most_common():
    by = request.args.get("by", "viewCount")
    counter = field_counter.get(by, {})
    if not counter:
        return jsonify({"error": "No data"}), 400
    val = max(counter.items(), key=lambda x: x[1])
    return jsonify({"value": val[0], "count": val[1]})


@app.route("/count_exact")
def count_exact():
    by = request.args.get("by", "viewCount")
    try:
        value = int(request.args.get("value", -1))
    except:
        return jsonify({"error": "Invalid value"}), 400

    count = field_counter.get(by, {}).get(value, 0)
    return jsonify({"value": value, "count": count})


@app.route("/count_prefix")
def count_prefix():
    by = request.args.get("by", "viewCount")
    prefix = request.args.get("prefix", "")

    trie = field_trie.get(by)
    if not trie:
        return jsonify({"error": "Field not supported for prefix"}), 400

    items = trie.search_prefix(prefix)
    try:
        sorted_items = sorted(items, key=lambda x: x[by], reverse=True)
    except:
        return jsonify({"error": "Sort error, check field type"}), 400

    return jsonify(sorted_items)


if __name__ == "__main__":
    app.run(debug=True)
