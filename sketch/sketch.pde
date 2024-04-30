PImage img;
String startTimestamp = timestamp();
VineBrush vnBrush;
ArrayList<VineBrush> brushes = new ArrayList<VineBrush>();
import java.util.Date;
import java.text.SimpleDateFormat;
import java.io.File;
import java.util.ArrayList;
String directoryPath = "/absolute-path-to-data-directory";

String timestamp() {
    Date date = new Date();
    SimpleDateFormat sdf = new SimpleDateFormat("yyMMdd-HHmmss-SSS");
    return sdf.format(date);
}

boolean isBrushMoving = true;

public void settings() {
    size(996, 560);
    File folder = new File(directoryPath);
    File[] listOfFiles =  folder.listFiles();
    ArrayList<String> imageFiles = new ArrayList<String>();
    
    for (File file : listOfFiles) {
        if (file.isFile()) {
            String fileName = file.getName();
            if (
                fileName.toLowerCase().endsWith(".png") || 
                fileName.toLowerCase().endsWith(".jpg") || 
                fileName.toLowerCase().endsWith(".jpeg")) {
                imageFiles.add(file.getPath());
            }
        }
    }
    
    if (imageFiles.size() > 0) {
        String randomImagePath = imageFiles.get((int)random(imageFiles.size()));
        img = loadImage(randomImagePath);
        
        float aspectRatio = img.width / (float)img.height;
        int newWidth = 996;
        int newHeight = int(newWidth / aspectRatio);
        img.resize(newWidth, newHeight);
        
    } else {
        println("No image files found in the directory.");
    }
}

void setup() {
    frameRate(60);
    background(10);
    int brushCount = 3;
    int segmentCount = 500;
    for (int i = 0; i < brushCount; i++) {
        brushes.add(new VineBrush(random(width),random(height),segmentCount));
    }
}

void draw() {
    if (isBrushMoving) {  // Update and draw only it is true
        for (VineBrush brush : brushes) {
            if (mousePressed) {
                brush.setPos(mouseX, mouseY);
            } else {
                brush.addToPos(random( -brush.step, brush.step), random( -brush.step, brush.step));
            }
            brush.updateSegmentsPos().draw();
        }
    }
}

class VineBrush{
    float xPos, yPos;
    int segments;
    float r =.1;
    float step;
    PVector[] posArr;
    float dist;
    float strokeWgt;
    float noiseScale;
    float fillAlpha;
    float strokeAlpha;
    float scale; 
    
    float rand = random(1);
    int currentMode = -1;
    
    void setMode(int mode) {
        if (currentMode != mode) {
            currentMode = mode;
            switch(mode) {
                case 0:
                    dist = 1;
                    step = 100;
                    strokeWgt =.1;
                    noiseScale = 0.05;
                    fillAlpha = 10;
                    strokeAlpha = 250;
                    scale = 4;
                    smooth();
                    break;
                case 1:
                    dist = 1;
                    step = 100;
                    strokeWgt = 1;
                    noiseScale = 0.5;
                    fillAlpha = 20;
                    strokeAlpha = 20;
                    scale = 20;
                    break;
            }
        }
    }
    
    VineBrush(float x, float y, int segmentCounts) {
        xPos = x;
        yPos = y;
        segments = segmentCounts; 
        posArr = new PVector[segments];
        
        for (int i = 0; i < segments; ++i) {
            posArr[i] = new PVector(x, y);
        }
    }
    
    VineBrush setPos(float x,  float y) {
        xPos = constrain(x, 1, width - 5);
        yPos = constrain(y, 1, height - 5);
        return this;
    }
    
    VineBrush addToPos(float x, float y) {
        return setPos(xPos += x, yPos += y);
    }
    
    VineBrush updateSegmentsPos() {
        posArr[0] = new PVector(xPos, yPos);
        for (int itr = 1; itr < segments; ++itr) {
            if (PVector.dist(posArr[itr], posArr[itr - 1]) > dist) {
                PVector tmpVector = PVector.sub(posArr[itr - 1], posArr[itr]).normalize().mult(dist);
                posArr[itr] = PVector.sub(posArr[itr - 1], tmpVector);
            }
        }
        return this;
    }
    
    void draw() {
        for (int i = segments - 1; i > - 1; --i) {
            pushMatrix();
            fill(getImgColor(img, posArr[i].x, posArr[i].y, fillAlpha));
            translate(posArr[i].x, posArr[i].y);
            stroke(getImgColor(img,posArr[i].x + 5, posArr[i].y + 5, strokeAlpha));
            strokeWeight(strokeWgt);
            if (i > 0) {
                rotate(atan2(posArr[i].y - posArr[i - 1].y, posArr[i].x - posArr[i - 1].x));
            }
            float noisyR = r / 2 + noise(posArr[i].x * noiseScale, posArr[i].y * noiseScale) * scale; 
            ellipse(0, 0, noisyR * 2, noisyR * 2);
            popMatrix();
        }
    }
}

color getImgColor(PImage img, float x, float y, float alpha) {
    x = constrain(x, 0, img.width - 1);
    y = constrain(y, 0, img.height - 1);
    int c = img.get((int)x,(int)y);
    return color(red(c), green(c), blue(c), alpha);
}

void loadRandomImage() {
    File folder = new File(directoryPath);
    File[] listOfFiles = folder.listFiles();
    ArrayList<String> imageFiles = new ArrayList<String>();
    
    for (File file : listOfFiles) {
        if (file.isFile()) {
            String fileName = file.getName();
            if (fileName.toLowerCase().endsWith(".png") || 
                fileName.toLowerCase().endsWith(".jpg") || 
                fileName.toLowerCase().endsWith(".jpeg")) {
                imageFiles.add(file.getPath());
            }
        }
    }
    
    if (imageFiles.size() > 0) {
        String randomImagePath = imageFiles.get((int)random(imageFiles.size()));
        img = loadImage(randomImagePath);
        float aspectRatio = img.width / (float)img.height;
        int newWidth, newHeight;
        if (width / (float)height > aspectRatio) {
            newHeight = height;
            newWidth = int(height * aspectRatio);
        } else {
            newWidth = width;
            newHeight = int(width / aspectRatio);
        }
        img.resize(newWidth, newHeight); 
    } else {
        println("No image files found in the directory.");
    }
}

void keyPressed() {
    
    if (key == 's') {
        save("./dist/sketch-" + timestamp() + ".png");
    } else if (key == '0') {
        background(0);
        loadRandomImage();
        isBrushMoving = false;
        println("Refreshed. Press `1` or `2`");
    } else if (key == '1') {
        isBrushMoving = true;
        println("Vine drawing mode");
        for (VineBrush brush : brushes) {
            brush.setMode(0);
        }
    } else if (key == '2') {
        isBrushMoving = true;
        println("Painting mode");
        for (VineBrush brush : brushes) {
            brush.setMode(1);
        }
    } 
}