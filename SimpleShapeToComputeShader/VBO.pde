import java.nio.*;

public class VBOInterleaved implements ShaderSource {
  final static short VRT_CMP_COUNT = 4; //Number of component per vertex
  final static short CLR_CMP_COUNT = 4; //Number of component per color
  /*define layout for interleaved VBO
   xyzwrgbaxyzwrgbaxyzwrgba...
   
   |v1       |v2       |v3       |... vertex
   |0   |4   |8   |12  |16  |20  |... offset
   |xyzw|rgba|xyzw|rgba|xyzw|rgba|... components
   
   stride (values per vertex) is 8 floats
   vertex offset is 0 floats (starts at the beginning of each line)
   color offset is 4 floats (starts after vertex coords)
   
   |0   |4   |8
   v1 |xyzw|rgba|
   v2 |xyzw|rgba|
   v3 |xyzw|rgba|
   |...
   */

  final static short NBR_COMP    =  VRT_CMP_COUNT + CLR_CMP_COUNT;
  final static short STRIDE      = (VRT_CMP_COUNT + CLR_CMP_COUNT) * Float.BYTES;
  final static short VRT_OFFSET  =                               0 * Float.BYTES;
  final static short CLR_OFFSET  =                   CLR_CMP_COUNT * Float.BYTES;

  private float[] VBOi;
  private int vertexCount;
  private FloatBuffer attributeBuffer;
  private int attributeVboId;
  private PShader shader;
  private PApplet parent;

  public VBOInterleaved(PApplet parent) {
    this.parent = parent;
    this.init();
  }

  public void init() {
    this.shader = new PShader(this.parent, this.vertSource, this.fragSource);
  }

  private void initVBO(PGL pgl, int handle, FloatBuffer data) {
    this.attributeVboId = handle;
    // Select the VBO, GPU memory data, to use for vertices
    pgl.bindBuffer(GL2ES2.GL_ARRAY_BUFFER, attributeVboId);
    // transfer data to VBO, this perform the copy of data from CPU -> GPU memory
    pgl.bufferData(GL.GL_ARRAY_BUFFER, data.limit() * Float.BYTES, data, GL.GL_DYNAMIC_DRAW);
  }

  public void update(PGL pgl, int COUNT, FloatBuffer data) {
    // Select the VBO, GPU memory data, to use for vertices
    pgl.bindBuffer(GL2ES2.GL_ARRAY_BUFFER, attributeVboId);

    // transfer data to VBO, this perform the copy of data from CPU -> GPU memory
    pgl.bufferSubData(GL.GL_ARRAY_BUFFER, COUNT * Float.BYTES * NBR_COMP, COUNT * Float.BYTES * NBR_COMP, data);
    
    // unbind buffer
    pgl.bindBuffer(GL2ES2.GL_ARRAY_BUFFER, 0);
  }

  public void render(PGraphics context, int COUNT) {
    PGL pgl = context.beginPGL();
    this.shader.bind();
    //send uniform to shader if necessary
    //...

    //get attributes location
    int vrtLoc = pgl.getAttribLocation(this.shader.glProgram, "vertex");
    pgl.enableVertexAttribArray(vrtLoc);

    int clrLoc = pgl.getAttribLocation(this.shader.glProgram, "color");
    pgl.enableVertexAttribArray(clrLoc);

    //bind VBO
    pgl.bindBuffer(PGL.ARRAY_BUFFER, this.attributeVboId);

    //fill data
    //pgl.bufferData(PGL.ARRAY_BUFFER, Float.BYTES * this.VBOi.length, this.attributeBuffer, PGL.STATIC_DRAW);//USE PGL.STATIC_DRAW if attributes are not set to be update by the CPU

    // Associate Vertex attribute 0 with the last bound VBO
    pgl.vertexAttribPointer(vrtLoc, VRT_CMP_COUNT, PGL.FLOAT, false, STRIDE, VRT_OFFSET);
    pgl.vertexAttribPointer(clrLoc, CLR_CMP_COUNT, PGL.FLOAT, false, STRIDE, CLR_OFFSET);
    
    
    //draw buffer
    pgl.drawArrays(PGL.POINTS, 0, COUNT);

    //disable arrays
    pgl.disableVertexAttribArray(vrtLoc);
    pgl.disableVertexAttribArray(clrLoc);

    //undind VBO
    pgl.bindBuffer(PGL.ARRAY_BUFFER, 0);

    //unbind shader
    this.shader.unbind();

    context.endPGL();
  }

  //utils
  private FloatBuffer allocateDirectFloatBuffer(int n) {
    return ByteBuffer.allocateDirect(n * Float.BYTES).order(ByteOrder.nativeOrder()).asFloatBuffer();
  }

  public void dispose() {
  }
}

static interface ShaderSource {
  public final static String[] vertSource = {
    "#version 150", 
    "uniform mat4 transform;", 
    "uniform mat4 projection;",
    "uniform mat4 modelview;",
    "in vec4 vertex;", 
    "in vec4 color;", 
    "out vec4 vertColor;", 
    "void main(){", 
    "gl_PointSize = 15f;",
    "gl_Position = projection * modelview * vertex;", 
    "vertColor = color;", 
    "}"
  };

  public final static String[] fragSource = {
    "#version 150", 
    "#ifdef GL_ES", 
    "precision mediump float;", 
    "precision mediump int;", 
    "#endif", 
    "in vec4 vertColor;", 
    "void main() {", 
    "vec2 uv = gl_PointCoord;",
    "gl_FragColor = vertColor * 1.0 + vec4(uv, 0, vertColor.w);", 
    "}"
  };
}
