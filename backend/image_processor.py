from PIL import Image, ImageStat
import os

class ImageProcessor:
    VALID_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'}
    
    def is_valid_image(self, filepath):
        try:
            ext = os.path.splitext(filepath)[1].lower()
            return ext in self.VALID_EXTENSIONS
        except:
            return False
    
    def get_metadata(self, filepath):
        try:
            img = Image.open(filepath)
            return {
                'width': img.width,
                'height': img.height,
                'format': img.format,
                'mode': img.mode,
                'size_bytes': os.path.getsize(filepath),
            }
        except Exception as e:
            return {'error': str(e)}
    
    def analyze(self, filepath):
        try:
            img = Image.open(filepath).convert('RGB')
            
            brightness = self._analyze_brightness(img)
            contrast = self._analyze_contrast(img)
            saturation = self._analyze_saturation(img)
            
            tags = self._generate_tags(brightness, contrast, saturation)
            quality_score = self._calculate_quality_score(brightness, contrast, saturation)
            
            return {
                'brightness': brightness,
                'contrast': contrast,
                'saturation': saturation,
                'tags': tags,
                'quality_score': quality_score,
                'description': self._generate_description(tags),
            }
        except Exception as e:
            return {'error': str(e)}
    
    def _analyze_brightness(self, img):
        stat = ImageStat.Stat(img)
        brightness = sum(stat.mean) / 3
        return round(brightness, 2)
    
    def _analyze_contrast(self, img):
        stat = ImageStat.Stat(img)
        contrast = sum(stat.stddev) / 3
        return round(contrast, 2)
    
    def _analyze_saturation(self, img):
        try:
            hsv_img = img.convert('HSV')
            stat = ImageStat.Stat(hsv_img)
            saturation = stat.mean[1]
            return round(saturation, 2)
        except:
            return 0.0
    
    def _generate_tags(self, brightness, contrast, saturation):
        tags = []
        
        if brightness > 150:
            tags.append('bright')
        elif brightness < 100:
            tags.append('dark')
        
        if saturation > 100:
            tags.append('vibrant')
        else:
            tags.append('muted')
        
        if contrast > 50:
            tags.append('high-contrast')
        
        return tags
    
    def _calculate_quality_score(self, brightness, contrast, saturation):
        score = 0
        
        if 80 < brightness < 180:
            score += 25
        
        if contrast > 30:
            score += 25
        
        if saturation > 50:
            score += 25
        
        score += 25  # Base score
        
        return min(100, max(0, score))
    
    def _generate_description(self, tags):
        descriptions = {
            'bright': 'Well-lit image',
            'dark': 'Low-light image',
            'vibrant': 'Vibrant colors',
            'muted': 'Muted colors',
            'high-contrast': 'High contrast',
        }
        
        desc_list = [descriptions.get(tag, tag) for tag in tags]
        return ', '.join(desc_list) if desc_list else 'Standard image'
