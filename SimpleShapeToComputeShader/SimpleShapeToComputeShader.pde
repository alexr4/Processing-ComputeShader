/**
 This skecth is a simple example of compute shader
 */

import fpstracker.core.*;
import com.jogamp.common.nio.Buffers;
import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2;
import com.jogamp.opengl.GL2ES2;
import com.jogamp.opengl.GL4;
import java.util.*;
import java.nio.*;
import peasy.*;

PerfTracker pt;
PGraphics trackers;
String datapath;

PeasyCam cam;

PJOGL pgl;
GL4 gl;
float scale = 25;

PShape shape;
ArrayList<Float> idata;
PointCloud pcl;
int subdivLevel = 0;

boolean init;

void settings() {
  size(720, 720, P3D);
  smooth(8);
}

void setup() {

  surface.setLocation(displayWidth/2 - width/2, -displayHeight/2 - height/2);
  pt = new PerfTracker(this, 120);
  trackers = createGraphics(pt.getActualPannel().width, pt.getActualPannel().height);

  datapath = sketchPath("../data/");

  println("Processing PGraphicsOpenGL capabilities");
  println("\t", PGraphicsOpenGL.OPENGL_VENDOR);
  println("\t", PGraphicsOpenGL.OPENGL_RENDERER);
  println("\t", PGraphicsOpenGL.OPENGL_VERSION);
  println("\t", PGraphicsOpenGL.GLSL_VERSION);
  //println("\t", PGraphicsOpenGL.OPENGL_EXTENSIONS);

  println("\nGL4 capabilities for compute shader");
  pgl = (PJOGL) beginPGL();  
  gl = pgl.gl.getGL4();

  //enable point size
  //https://www.informit.com/articles/article.aspx?p=770639&seqNum=7
  gl.glEnable(GL2.GL_POINT_SPRITE);
  ((GL2)gl).glTexEnvi(GL2.GL_POINT_SPRITE, GL2.GL_COORD_REPLACE, GL2.GL_TRUE);
  ((GL2)gl).glPointParameteri(GL2.GL_POINT_SPRITE_COORD_ORIGIN, GL2.GL_LOWER_LEFT);
  gl.glEnable(GL4.GL_PROGRAM_POINT_SIZE);

  //infos
  //IntBuffer result = IntBuffer.allocate(1);
  //gl.glGetIntegerv(GL2.GL_MAX_VERTEX_ATTRIBS, result);
  //println("\t", "GL_MAX_VERTEX_ATTRIBS: ", result.get(0));

  //IntBuffer xbuffer = IntBuffer.allocate(1);
  //IntBuffer ybuffer = IntBuffer.allocate(1);
  //IntBuffer zbuffer = IntBuffer.allocate(1);
  //gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_SIZE, 0, xbuffer);
  //gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_SIZE, 1, ybuffer);
  //gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_SIZE, 2, zbuffer);
  //println("\t", "GL_MAX_COMPUTE_WORK_GROUP_SIZE: ", xbuffer.get(0), ybuffer.get(0), zbuffer.get(0));

  //gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 0, xbuffer);
  //gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 1, ybuffer);
  //gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 2, zbuffer);
  //println("\t", "GL_MAX_COMPUTE_WORK_GROUP_COUNT: ", xbuffer.get(0), ybuffer.get(0), zbuffer.get(0));

  //gl.glGetIntegerv(GL4.GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS, result);
  //println("\t", "GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS: ", result.get(0));



  cam = new PeasyCam(this, 0, -325, 0, 250);

  frameRate(60);
}

void draw() {
  if (!init) {
    println("load obj");
    shape = loadShape(datapath+"Lilium/Flower1.obj");
    PImage texture = loadImage(datapath+"Lilium/Flower1.png");
    texture.loadPixels();
    println("shape loaded");

    println("compute vertex and color");
    idata = new ArrayList<Float>();
    for (int i=0; i<shape.getChildCount(); i++) {
      PShape child = shape.getChild(i);

      Float[] A   = getVertexData(child, texture, scale, 0);
      Float[] B   = getVertexData(child, texture, scale, 1);
      Float[] C   = getVertexData(child, texture, scale, 2);

      ArrayList<Float[]> list = new ArrayList<Float[]>();
      int level = subdivLevel;

      getRecursiveData(A, B, C, level, list);

      for (int k=0; k<list.size(); k++) {
        pushData(list.get(k), idata);
      }
    }

    println("create PCL");
    pcl = new PointCloud(this, pgl, gl, g);
    pcl.init(idata.size());
    pcl.setPoints(idata);
    pcl.initVBO();
    println("point cloud ready with "+pcl.pclCount);

    init = true;
  } else {
    background(20);

    float nmx = norm(mouseX, 0, width);
    // pushMatrix();
    //translate(width/2, height/2, -2000 * nmx);
    //rotateX(frameCount * 0.001);
    // rotateY(frameCount * 0.000125);

    //pcl.execute();
    //pcl.updateGPUData();
    //pcl.getGPUData();//If necessary
    strokeCap(SQUARE);
    pcl.render(g);

    axis(100);
    // popMatrix();

    trackers.beginDraw();
    trackers.image(pt.getActualPannel(), 0, 0);
    trackers.endDraw();

    cam.beginHUD();
    g.image(trackers, 0, 0);
    fill(255);
    text("Number of particles: "+pcl.pclCount, 110, 20);
    cam.endHUD();
  }
}

void keyPressed() {
  switch(key) {
  case 'i' :
    pcl.dispose();

    pcl.init(idata.size());
    pcl.setPoints(idata);
    pcl.initVBO();
    break;
  case 's' :
    save("pcl_"+pcl.pclCount+".png");
    break;
  }
}

public void axis(int len) {
  stroke(255, 0, 0);
  line(0, 0, 0, len, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, len, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, len);
}


@Override void exit() {
  pcl.dispose();
  super.exit();
}
