class Trail {

    List<PVector[]> segments;
    int size;

    Trail(int size) {
        segments = new ArrayList<PVector[]>();
        this.size = size;
    }

    void addSegment(PVector start, PVector end) {
        PVector[] s = new PVector[] {start, end};
        if (end.copy().sub(start).mag() > 0) {
            segments.add(s);
        }
        if (segments.size() > size) {
            segments.remove(0);
        }
    }

    void draw() {
        boolean isPendingBeginShape = false;
        noFill();
        stroke(trailColorR, trailColorG, trailColorB, trailColorAlpha);
        strokeWeight(trailWeight);
        beginShape();
        for (PVector[] s : segments) {
            if (Float.isInfinite(s[0].x)) {
                // Check if the start of the segment has infinite x coordinate. This is used to indicate a WRAP boundmode has been applied, and hence a new path should be started.
                endShape();
                isPendingBeginShape = true;
            } else {
                if (isPendingBeginShape) {
                    beginShape();
                    isPendingBeginShape = false;
                }
                vertex(s[0].x, s[0].y);
                vertex(s[1].x, s[1].y);
            }
        }
        endShape();
    }

    void setSize(int i) {
        int removalCount = segments.size() - i;
        if (removalCount > 0) {
            segments.subList(0, removalCount - 1).clear();
        }
        size = i;
    }

}
