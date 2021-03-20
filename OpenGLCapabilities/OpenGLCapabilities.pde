/**
This skecth display the GPU capabilities for compute shaders.
*/
import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL2;
import com.jogamp.opengl.GL4;
import java.nio.*;

PJOGL pgl;
GL4 gl;

void settings() {
  size(10, 10, P2D);
  //PJOGL.profile = 4; //It seams it's not necessary to define this profile to access capabilities
}

void setup() {
  println("Processing PGraphicsOpenGL capabilities");
  println("\t", PGraphicsOpenGL.OPENGL_VENDOR);
  println("\t", PGraphicsOpenGL.OPENGL_RENDERER);
  println("\t", PGraphicsOpenGL.OPENGL_VERSION);
  println("\t", PGraphicsOpenGL.GLSL_VERSION);
  //println("\t", PGraphicsOpenGL.OPENGL_EXTENSIONS);

  println("\nGL4 capabilities for compute shader");
  pgl = (PJOGL) beginPGL();  
  gl = pgl.gl.getGL4();
  
  /**
  the glGet... function allow to retreive value from a parameter. Here the parameter are the GPU capabilities constant.
  It works with IntBuffer, FloatBuffer...
  more info on https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/glGet.xhtml
  */
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
}

void draw() {
}
