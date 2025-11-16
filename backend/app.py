from flask import Flask, jsonify, request
from flask_cors import CORS
import os
from pathlib import Path
import json
from datetime import datetime
from image_processor import ImageProcessor

app = Flask(__name__)
CORS(app)

# Configuration
GALLERY_PATH = os.path.expanduser('~/Pictures')
CACHE_FILE = 'image_cache.json'
CACHE_DURATION = 300  # 5 minutes

image_processor = ImageProcessor()
last_cache_time = 0
cached_images = []

def get_gallery_images():
    global last_cache_time, cached_images
    
    current_time = datetime.now().timestamp()
    
    # Check cache
    if current_time - last_cache_time < CACHE_DURATION and cached_images:
        return cached_images
    
    images = []
    if not os.path.exists(GALLERY_PATH):
        return images
    
    for filename in os.listdir(GALLERY_PATH):
        filepath = os.path.join(GALLERY_PATH, filename)
        if os.path.isfile(filepath):
            if image_processor.is_valid_image(filepath):
                try:
                    stat = os.stat(filepath)
                    images.append({
                        'path': filepath,
                        'name': filename,
                        'size': stat.st_size,
                        'modified': datetime.fromtimestamp(stat.st_mtime).isoformat(),
                    })
                except:
                    pass
    
    cached_images = images
    last_cache_time = current_time
    return images

@app.route('/api/health', methods=['GET'])
def health():
    return jsonify({'status': 'ok', 'message': 'Server is running'}), 200

@app.route('/api/images', methods=['GET'])
def get_images():
    images = get_gallery_images()
    return jsonify({'images': images, 'count': len(images)}), 200

@app.route('/api/search', methods=['GET'])
def search_images():
    query = request.args.get('q', '').lower()
    if not query:
        return jsonify({'results': [], 'query': query, 'count': 0}), 200
    
    images = get_gallery_images()
    results = [img for img in images if query in img['name'].lower()]
    return jsonify({'results': results, 'query': query, 'count': len(results)}), 200

@app.route('/api/analyze', methods=['POST'])
def analyze_image():
    data = request.get_json()
    path = data.get('path', '')
    
    if not path or not os.path.exists(path):
        return jsonify({'error': 'Image not found'}), 404
    
    analysis = image_processor.analyze(path)
    return jsonify(analysis), 200

@app.route('/api/metadata', methods=['GET'])
def get_metadata():
    path = request.args.get('path', '')
    if not path or not os.path.exists(path):
        return jsonify({'error': 'Image not found'}), 404
    
    metadata = image_processor.get_metadata(path)
    return jsonify(metadata), 200

@app.route('/api/cache/clear', methods=['POST'])
def clear_cache():
    global last_cache_time, cached_images
    last_cache_time = 0
    cached_images = []
    return jsonify({'message': 'Cache cleared'}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
