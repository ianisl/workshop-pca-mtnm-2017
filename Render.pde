import java.util.Calendar;
import java.io.InputStreamReader;

// Classes named Render* (RenderCustom, RenderBase, Render, ...) define rendering jobs.
// To define custom rendering jobs outside these classes, a Renderer interface must be implemented.

public class Render extends RenderBase {
    // Basic renderer.
    // Export to jpg or pdf (this will only work
    // if the sketch is using Processing shape primitives).
    boolean isRenderingJpg = false;
    boolean isRenderingPdf = false;
    boolean hasRenderingStarted = false;
    String renderer;
    String filePathWithoutExtension;

    Render(PApplet applet, String path) {
        super(applet, path);
        applet.registerMethod("pre", this);
        applet.registerMethod("draw", this);
        renderer = applet.g.getClass().getName();
    }

    void pre() {
        // The following code will be called just before the main applet's draw method
        if (isRenderingPdf || isRenderingJpg) {
            filePathWithoutExtension = baseRenderPath + today + "-" + runId + "-" + renderId;
            if (isRenderingPdf) {
                if (renderer.equals("processing.awt.PGraphicsJava2D") || renderer.equals("processing.opengl.PGraphics2D")) {
                    beginRecord(PDF, filePathWithoutExtension + ".pdf");
                } else if (renderer.equals(P3D)) {
                    beginRaw(PDF, filePathWithoutExtension + ".pdf");
                }
            }
            hasRenderingStarted = true;
        }
    }

    void draw() {
        // The following code will be called just after the main applet's draw() method
        // since the renderPdf method might be called in the middle of the main applet's draw method,
        // we need to check if pdf rendering has actually started.
        if (hasRenderingStarted) {
            if (isRenderingPdf) {
                if (renderer.equals(P2D) || renderer.equals(PDF)) {
                    endRecord();
                } else if (renderer.equals(P3D)) {
                    endRaw();
                }
                println("Saved PDF.");
                isRenderingPdf = false;
            }
            if (isRenderingJpg) {
                save(filePathWithoutExtension + ".jpg");
                println("Saved JPG.");
                isRenderingJpg = false;
            }
            hasRenderingStarted = false;
            renderId++;
        }
    }

    void renderPdf() {
        isRenderingPdf = true;
    }

    void renderPdfAndJpg() {
        isRenderingPdf = true;
        isRenderingJpg = true;
    }

    void renderJpg() {
        isRenderingJpg = true;
    }

    boolean isRendering () {
        return isRenderingJpg || isRenderingPdf;
    }

    boolean isRenderingPdf() {
        return isRenderingPdf;
    }

    boolean isRenderingJpg() {
        return isRenderingJpg;
    }

}

public class RenderCustom extends RenderBase {
    // A convenience class to use a custom renderer (implementing
    // the Renderer interface) with the RenderBase file system operations.
    Renderer renderer;

    RenderCustom(PApplet applet, String path, Renderer renderer) {
        super(applet, path);
        this.renderer = renderer;
    }

    void render() {
        renderer.render(baseRenderPath + today + "-" + runId + "-" + renderId); // Call custom renderer's render() method
        renderId++;
    }

}

public interface Renderer {
    public void render(String filePathWithoutExtension);
}

public class RenderBase {
    // This class contains the basic file system operations needed by renderers.
    String path; // absolute path to the folder where images should be recorded
    String baseRenderPath; // images are sorted in subfolders within "path". This is the current subfolder given git version and date
    String gitVersionHash;
    int runId; // for each day, the runId increases by 1 each time the program is launched and at least one image has been saved
    int renderId = 1; // for each run, the renderId increases by 1 each time an image is saved
    String today;
    boolean hasRenderingStarted = false;

    RenderBase(PApplet applet, String path) {
        if (!path.endsWith(java.io.File.separator)) {
            path += java.io.File.separator;
        }
        this.path = path;
        today = getTimeStamp();
        baseRenderPath = path + today + java.io.File.separator;
        runId = getRunId();
    }

    String getTimeStamp() {
        Calendar now = Calendar.getInstance();
        return String.format("20%1$ty-%1$tm-%1$td", now);
    }

    int getRunId() {
        String[] fileNames = listFileNames(baseRenderPath);
        if (fileNames != null) {
            // if some images were previously recorded for this version
            int runId = 0; // We start at 0: if no previous runId is found, runId will be increased to 1
            for (String n : fileNames) {
                if (n.startsWith(today)) {
                    // if at least one image was previously recorded on this day
                    String[] s = n.split("-");
                    int id = Integer.parseInt(s[3]);
                    if (id > runId) {
                        runId = id; // we want to retrieve the highest runId
                    }
                }
            }
            runId++;
            return runId;
        } else {
            // if no image was previously recorded for this version, start runId at 1
            return 1;
        }
    }

    String[] listFileNames(String dir) {
        File file = new File(dir);
        if (file.isDirectory()) {
            String names[] = file.list();
            return names;
        } else {
            return null;
        }
    }

}
