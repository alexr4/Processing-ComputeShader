Float[] getVertexData(PShape shape, PImage texture, float scale, int i) {
  PVector vertex = shape.getVertex(i);
  vertex.mult(scale);
  float u = shape.getTextureU(i);
  float v = shape.getTextureV(i);
  int x = floor(u * texture.width);
  int y = floor(v * texture.height);
  int index = x + y * texture.width;
  int pixelColor = texture.pixels[index];
  float red = (pixelColor >> 16 & 0xFF) / 255.0;
  float green = (pixelColor >> 8 & 0xFF) / 255.0;
  float blue = (pixelColor & 0xFF) / 255.0;


  return new Float[]{vertex.x, vertex.y, vertex.z, red, green, blue};
}

void getRecursiveData(Float[] A, Float[] B, Float[] C, int level, ArrayList<Float[]> list) {
  if (level == 0) {
    Float[] G   = getGravityVertex(A, B, C);
    list.add(G);
  } else {
    Float[] G   = getGravityVertex(A, B, C);
    level --;
    getRecursiveData(A, B, G, level, list);
    getRecursiveData(B, C, G, level, list);
    getRecursiveData(C, A, G, level, list);
  }
}

Float[] getGravityVertex(Float[] A, Float[] B, Float[] C) {
  return new Float[]{(A[0] + B[0] + C[0]) / 3.0, 
    (A[1] + B[1] + C[1]) / 3.0, 
    (A[2] + B[2] + C[2]) / 3.0, 
    (A[3] + B[3] + C[3]) / 3.0, 
    (A[4] + B[4] + C[4]) / 3.0, 
    (A[5] + B[5] + C[5]) / 3.0};
}

void pushData(Float[] data, ArrayList<Float> dst) {
  //vertex
  dst.add(data[0]);
  dst.add(data[1]);
  dst.add(data[2]);
  dst.add(1.0);

  //color
  dst.add(data[3]);
  dst.add(data[4]);
  dst.add(data[5]);
  dst.add(1.0);
}
