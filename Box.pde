class Box extends Rect {
  Box(float x, float y, float sizeX, float sizeY) {
    super(x, y, sizeX, sizeY);
  }
}

class Platform extends Box {
  Platform(float x, float y, float sizeX) {
    super(x, y, sizeX, 1);
  }
}