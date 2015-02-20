import controlP5.*;

import gab.opencv.*; 
import org.opencv.core.*; 
import SimpleOpenNI.*;
import java.awt.Rectangle;

/* --------------------------------------------------------------------------
 * SimpleOpenNI IR Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */


Work work;

OpenCV cv;
SimpleOpenNI  context;
ControlP5 ui;        

import java.util.Map;
import java.util.Iterator;     

float PADDING = 10;
int SLIDER_WIDTH = 100;
int SLIDER_HEIGHT = 20;
float SLIDER_SPACING = 1;
  
int brightness;
int contrast;

float work_flow_min=1;
float work_flow_mult=20;

Rectangle roi;
long roi_date;

ArrayList<Contour> contours;
int          handVecListSize = 30;
Map<Integer,ArrayList<PVector>>  handPathList = new HashMap<Integer,ArrayList<PVector>>();
color[]       userClr = new color[]{ color(255,0,0),
                                     color(0,255,0),
                                     color(0,0,255),
                                     color(255,255,0),
                                     color(255,0,255),
                                     color(0,255,255)
                                   };
void setup()
{
  size(640, 480, P2D);
  frameRate(12);
  
  work = new Work();
  this.registerDispose(work);
  
  cv = new OpenCV(this, 640, 480);
  context = new SimpleOpenNI(this);
  ui = new ControlP5(this);
  roi = new Rectangle(0,0,0,0);
  roi_date = millis()+100;
  
  Slider sliders[] = {
    ui.addSlider("brightness").setRange(-255,255).setValue(-234),
    ui.addSlider("contrast").setRange(-255,255*8).setValue(915),
    ui.addSlider("work_flow_min").setRange(0.5,2).setValue(0.5),
    ui.addSlider("work_flow_mult").setRange(1,100).setValue(95)
  };
  for(int i=0; i < sliders.length; i++) {
    sliders[i].setHeight(SLIDER_HEIGHT).setWidth(SLIDER_WIDTH)
    .setPosition(PADDING,PADDING+i*(SLIDER_HEIGHT+SLIDER_SPACING));
  }
  
  if(context.isInit() == false)
  {
     println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
     exit();
     return;  
  }
  
  // enable depthMap generation 
  context.enableDepth();
  
  // enable ir generation
  context.enableIR();
  context.setMirror(false);
  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_WAVE);
  //context.enableUser();
  
  background(200,0,0);
}

void draw()
{
  // update the cam
  context.update();
  work.update();
  // draw depthImageMap
  //image(context.depthImage(),0,0);
  cv.loadImage(context.depthImage());
  
  cv.brightness(brightness);
  cv.contrast(contrast/127.0f);
  
  
  background(60);
  image(cv.getSnapshot(),0,0);
  blendMode(MULTIPLY);
  image(cv.getSnapshot(),0,0);
  blendMode(BLEND);
  cv.brightness(50);
  Rectangle roi2 = new Rectangle(0,0,0,0);
  
  if(false) {
    contours = cv.findContours(true,true);
    int maxScore = width*height;
    for (Contour contour : contours) {
      fill(255);
      noStroke();
      ArrayList<PVector> poly = contour.getPolygonApproximation().getPoints();
      PVector avg = new PVector();
      //beginShape();
      for( PVector pt : poly ) {
        avg.add(pt);
        //vertex(pt.x,pt.y);
      }
      //endShape();
      //cv.fitEllipse2(poly);
      //ArrayList<PVector> hull = new ArrayList<PVector>();
      //cv.convexHull(poly,hull);
      
      noFill();
      Rectangle r = contour.getBoundingBox();
      if(r.width<15) continue;
      stroke(0,255,0,32);
      rect(r.x,r.y,r.width,r.height);
      int score = r.width*r.height;
      if(score > roi2.width*roi2.height && score < 0.8*maxScore) roi2 = r;
    }
    //cv.setROI(roi.x,roi.y,roi.width,roi.height);
    noFill();
    stroke(255,0,0,64);
    //rect(roi2.x,roi2.y,roi2.width,roi2.height);
    //rect(roi.x,roi.y,roi.width,roi.height);
    line(roi2.x+roi2.width/2,roi2.y+roi2.height/2,roi.x+roi.width/2,roi.y+roi.height/2);
    if(millis() > roi_date) {
      roi = roi2;
      roi_date+=100;
      //println("updating roi"+roi.x);
    }
  }
  
  String type = "flow";
  
  if (type=="canny") {
    cv.findCannyEdges(20,75);
    blendMode(ADD);
    image(cv.getSnapshot(),0,0);
    blendMode(BLEND);
  } else if(type=="flow") {
    stroke(255,0,0,64);
    cv.calculateOpticalFlow();
    cv.drawOpticalFlow();
    int flowmag = round(cv.getAverageFlow().magSq()*work_flow_mult);
    if(flowmag < work_flow_min)
      work.stop();
    else {
      work.start();
      work.score += flowmag;
    }
    //PVector flow = PVector.mult(cv.getAverageFlowInRegion(roi.x,roi.y,roi.width,roi.height),1000);
    pushMatrix();
    //line(roi.x+roi.width/2,roi.y+roi.height/2,roi.x+roi.width/2+flow.x,roi.y+roi.height/2+flow.y);
    //ellipse(roi.x+roi.width/2+flow.x,roi.y+roi.height/2+flow.y,15,15);
    popMatrix(); 
    //blendMode(ADD);
    //image(context.irImage(),0,0);
    //blendMode(BLEND);
  }
  //cv.releaseROI();
  
  work.draw();
}
