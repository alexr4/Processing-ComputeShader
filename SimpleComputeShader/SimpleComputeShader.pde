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

PeasyCam cam;

PJOGL pgl;
GL4 gl;

RandomParticlesWalker rndPartWalk;

void settings() {
  size(720, 720, P3D);
}

void setup() {
  pt = new PerfTracker(this, 120);
  trackers = createGraphics(pt.getActualPannel().width, pt.getActualPannel().height);

  println("Processing PGraphicsOpenGL capabilities");
  println("\t", PGraphicsOpenGL.OPENGL_VENDOR);
  println("\t", PGraphicsOpenGL.OPENGL_RENDERER);
  println("\t", PGraphicsOpenGL.OPENGL_VERSION);
  println("\t", PGraphicsOpenGL.GLSL_VERSION);
  //println("\t", PGraphicsOpenGL.OPENGL_EXTENSIONS);

  println("\nGL4 capabilities for compute shader");
  pgl = (PJOGL) beginPGL();  
  gl = pgl.gl.getGL4();


  IntBuffer result = IntBuffer.allocate(1);
  gl.glGetIntegerv(GL2.GL_MAX_VERTEX_ATTRIBS, result);
  println("\t", "GL_MAX_VERTEX_ATTRIBS: ", result.get(0));

  IntBuffer xbuffer = IntBuffer.allocate(1);
  IntBuffer ybuffer = IntBuffer.allocate(1);
  IntBuffer zbuffer = IntBuffer.allocate(1);
  gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_SIZE, 0, xbuffer);
  gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_SIZE, 1, ybuffer);
  gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_SIZE, 2, zbuffer);
  println("\t", "GL_MAX_COMPUTE_WORK_GROUP_SIZE: ", xbuffer.get(0), ybuffer.get(0), zbuffer.get(0));

  gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 0, xbuffer);
  gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 1, ybuffer);
  gl.glGetIntegeri_v(GL4.GL_MAX_COMPUTE_WORK_GROUP_COUNT, 2, zbuffer);
  println("\t", "GL_MAX_COMPUTE_WORK_GROUP_COUNT: ", xbuffer.get(0), ybuffer.get(0), zbuffer.get(0));

  gl.glGetIntegerv(GL4.GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS, result);
  println("\t", "GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS: ", result.get(0));

  rndPartWalk = new RandomParticlesWalker(this, pgl, gl, g);
  rndPartWalk.init();
  rndPartWalk.setRandomPointForWalking();
  rndPartWalk.initVBO();

  cam = new PeasyCam(this, 500);

  frameRate(300);
}

void draw() {
  background(20);

  float nmx = norm(mouseX, 0, width);
  // pushMatrix();
  //translate(width/2, height/2, -2000 * nmx);
  //rotateX(frameCount * 0.001);
  // rotateY(frameCount * 0.000125);

  rndPartWalk.execute();
  //rndPartWalk.updateGPUData();
  //rndPartWalk.getGPUData();//If necessary
  rndPartWalk.render(g);

  axis(100);
  // popMatrix();

  trackers.beginDraw();
  trackers.image(pt.getActualPannel(), 0, 0);
  trackers.endDraw();

  cam.beginHUD();
  g.image(trackers, 0, 0);
  fill(255);
  text("Number of particles: "+rndPartWalk.MAX_PARTICLES, 110, 20);
  cam.endHUD();
}

void keyPressed() {
  rndPartWalk.dispose();

  rndPartWalk.init();
  rndPartWalk.setRandomPointForWalking();
  rndPartWalk.initVBO();
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
  rndPartWalk.dispose();
  super.exit();
}
