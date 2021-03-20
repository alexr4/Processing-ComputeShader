public class RandomParticlesWalker {
  private final static int MAX_PARTICLES = 1000000;
  private PGL pgl;
  private GL4 gl;
  private PApplet app;
  private PGraphics ctx;

  //particles component
  private final static int COLORCOMP = 4;  
  private final static int POSCOMP = 4;  

  //compute shader + FloatBuffer to handle the datas
  private ComputeProgram rndWalkCompute;
  private FloatBuffer rndWalkerBuffer;
  private int rndWalkerHandle;

  private VBOInterleaved vbo;

  public RandomParticlesWalker(PApplet app, PGL pgl, GL4 gl, PGraphics ctx) {
    this.app = app;
    this.pgl = pgl;
    this.gl = gl;
    this.ctx = ctx;
  }

  public void init() {
    //init Float Buffer
    rndWalkerBuffer = Buffers.newDirectFloatBuffer(MAX_PARTICLES * (POSCOMP + COLORCOMP)); 

    //initVBO
    vbo = new VBOInterleaved(app);

    rndWalkCompute = new ComputeProgram(gl, loadAsText("data/rndWalker.comp"));
    IntBuffer intBuffer = IntBuffer.allocate(1);
    gl.glGenBuffers(1, intBuffer);
    rndWalkerHandle = intBuffer.get(0);
  }

  public void initVBO() {

    // Select the VBO, GPU memory data, to use for vertices -> update the VBO Object
    // transfer data to VBO, this perform the copy of data from CPU -> GPU memory
    vbo.initVBO(pgl, rndWalkerHandle, rndWalkerBuffer);
  }

  public void setRandomPointForWalking() {
    float BOXWIDTH = 1000;
    for (int i=0; i<MAX_PARTICLES; i++) {
      int NBR_COMP = COLORCOMP + POSCOMP;
      this.rndWalkerBuffer.put(i * NBR_COMP + 0, random(BOXWIDTH * - 0.5, BOXWIDTH * 0.5));
      this.rndWalkerBuffer.put(i * NBR_COMP + 1, random(BOXWIDTH * - 0.5, BOXWIDTH * 0.5));
      this.rndWalkerBuffer.put(i * NBR_COMP + 2, random(BOXWIDTH * - 0.5, BOXWIDTH * 0.5));
      this.rndWalkerBuffer.put(i * NBR_COMP + 3, 1);

      this.rndWalkerBuffer.put(i * NBR_COMP + 4, random(1.0));
      this.rndWalkerBuffer.put(i * NBR_COMP + 5, random(1.0));
      this.rndWalkerBuffer.put(i * NBR_COMP + 6, random(1.0));
      this.rndWalkerBuffer.put(i * NBR_COMP + 7, 1);
    }
  }

  public void updateGPUData() {
    // Select the VBO, GPU memory data, to use for vertices
    // transfer data to VBO, this perform the copy of data from CPU -> GPU memory
    // unbind buffer from VBO
    vbo.update(pgl, MAX_PARTICLES, rndWalkerBuffer);
  }

  public void execute() {
    rndWalkCompute.begin();

    //bind buffer for storage
    gl.glBindBufferBase(GL4.GL_SHADER_STORAGE_BUFFER, 0, rndWalkerHandle);
    
    //execute compute shader
    rndWalkCompute.compute(ceil(MAX_PARTICLES/1024.0), 1, 1); //check if the Working group is correct

    //unbind buffer
    gl.glBindBufferBase(GL4.GL_SHADER_STORAGE_BUFFER, 0, 0);
    rndWalkCompute.end();
  }

  public void getGPUData() {
    //None. For now we only send data to VBO and not retreiving data into a CPU Buffer
    //see https://github.com/alexr4/jogl-compute-shaders-fireworks for implementation example
  }

  public void render(PGraphics ctx) {
    //render VBO here
    vbo.render(ctx, MAX_PARTICLES);
  }

  public void dispose() {
    rndWalkCompute.dispose();
    vbo.dispose();
  }
}
