To 助教: 若需要，請使用elearing上傳附件內的API Key  
Repo內的API Key因為public因素移除。  

# Youtube Analyze Tool  
一個基於Youtube搜尋結果的簡易sorting前後端實作  
Flask & Flutter  

## Installation


### Backend API  
Install requirements.txt and insert your Youtube API key in config.py.  
Run app.py, the default IP and port is localhost:5000.  

### Frontend Interface  
Make sure the backend is already running, or define one by changing the IP&port target.  
All functions including generation are implemented in the backend.  
Nothing will work without the backend, the frontend is just a visualization.  


## API Usage  

### `GET /search`  
Fetch videos by search query and build indexes.  

**Parameters:**  
- `query` (string, required): Search keyword.  

**Response:**  
Returns a list of videos matching the search query.  

Example:  
```
GET /search?query=NKUST
```
  
---  

### `GET /sort`  
Sort the current dataset by a given field.  

**Parameters:**    
- `by` (string, optional): Field to sort by (default: `viewCount`).  
- `order` (string, optional): `desc` or `asc`(other cases treated as asc) (default: `desc`).  

**Response:**  
Returns a sorted list of videos.  

Example:  
```
GET /sort?by=likeCount&order=asc
```

---  

### `GET /nth`  
Get the N-th highest video by a specified field.  

**Parameters:**  
- `by` (string, optional): Field to rank by (default: `viewCount`).  
- `rank` (int, required): The rank (1 = highest).  

**Response:**    
Returns the N-th highest ranked video.  

Example:  
```
GET /nth?by=likeCount&rank=3
```

---  

### `GET /most_common`  
Find the most common value for a given field.  

**Parameters:**  
- `by` (string, optional): Field to analyze (default: `viewCount`).  

**Response:**    
Returns the most common value and its count.  

Example:  
```
GET /most_common?by=likeCount
```

---  

### `GET /count_exact`  
Count how many videos have an exact value for a given field.  

**Parameters:**  
- `by` (string, optional): Field to analyze (default: `viewCount`).  
- `value` (int, required): Exact value to count.  

**Response:**  
Returns the count of videos with the exact value.  

Example:  
```
GET /count_exact?by=likeCount&value=5000
```

---  

### `GET /prefix`  
Find videos where a field starts with a given prefix (only supported fields are indexed with trie).  

**Parameters:**  
- `by` (string, required): Field to search (must support prefix search).  
- `prefix` (string, required): Prefix string.  

**Response:**  
Returns a list of matching videos sorted by the same field (descending).  

Example:  
```
GET /prefix?by=viewCount&prefix=352
```

---  

### `GET /generate`  
Generate a dataset of 100,000 random video entries.  

**Response:**  
Returns the full generated dataset.  

Example:  
```
GET /generate
```

---  

## Notes  
- `data_store` is in-memory and shared across requests.  
- Endpoints like `/sort`, `/nth`, `/most_common`, etc. require a prior `/search` or `/generate` call to populate data.  
- Only `viewCount` and `likeCount` are implemented in the frontend interface, but more options can be sorted — for details, see [YouTube API v3 documentation](https://developers.google.com/youtube/v3/docs/videos#statistics).  
- Generated data follows the format of YouTube API search query return format.  
