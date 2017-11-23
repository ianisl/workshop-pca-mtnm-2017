class Agent {

    float x, y, z, vx, vy, vz, ax, ay, az;
    float xPrev, yPrev, zPrev;
    boolean isContrainedZ;
    Swarm swarm;
    Trail trail;

    Agent(Swarm swarm) {
        this.swarm = swarm;
        isContrainedZ = false;
        trail = new Trail(trailSize);
    }

    void setPos(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
        this.xPrev = x;
        this.yPrev = y;
        this.zPrev = z;
    }

    void setVel(float vx, float vy, float vz) {
        this.vx = vx;
        this.vy = vy;
        this.vz = vz;
    }

    void setTrailSize(int i) {
        trail.setSize(i);
    }

    void setZConstraintFlag(boolean b) {
        isContrainedZ = b;
    }

    void draw() {
        noStroke();
        fill(agentColorR, agentColorG, agentColorB, agentColorA);
        ellipse(x, y, agentDrawSize, agentDrawSize);
    }

    void drawTrail() {
        trail.draw();
    }

    void applyBounds() {
        switch (swarm.boundMode) {
            case CLAMP:
                if (x < swarm.minX) {
                    x = swarm.minX;
                    vx = -vx;
                    xPrev = x;
                }
                if (x > swarm.maxX) {
                    x = swarm.maxX;
                    vx = -vx;
                    xPrev = x;
                }
                if (y < swarm.minY) {
                    y = swarm.minY;
                    vy = -vy;
                    yPrev = y;
                }
                if (y > swarm.maxY) {
                    y = swarm.maxY;
                    vy = -vy;
                    yPrev = y;
                }
                if (z < swarm.minZ) {
                    z = swarm.minZ;
                    vz = -vz;
                    zPrev = z;
                }
                if (z > swarm.maxZ) {
                    z = swarm.maxZ;
                    vz = -vz;
                    zPrev = z;
                }
                break;
            case WRAP:
                // In this case, whenever an agent exits the screen, we set xPrev to NEGATIVE_INFINITY so we can use this to discard the drawing of the corresponding segment
                if (x < swarm.minX) {
                    x += swarm.boundsWidth;
                    xPrev = Float.NEGATIVE_INFINITY;
                }
                if (x > swarm.maxX) {
                    x -= swarm.boundsWidth;
                    xPrev = Float.NEGATIVE_INFINITY;
                }
                if (y < swarm.minY) {
                    y += swarm.boundsHeight;
                    xPrev = Float.NEGATIVE_INFINITY;
                }
                if (y > swarm.maxY) {
                    y -= swarm.boundsHeight;
                    xPrev = Float.NEGATIVE_INFINITY;
                }
                if (z < swarm.minZ) {
                    z += swarm.boundsDepth;
                    xPrev = Float.NEGATIVE_INFINITY;
                }
                if (z > swarm.maxZ) {
                    z -= swarm.boundsDepth;
                    xPrev = Float.NEGATIVE_INFINITY;
                }
                break;
        }
    }

    void update(float stepSize) {
        float acc[] = computeAcceleration(stepSize);
        ax = acc[0];
        ay = acc[1];
        az = isContrainedZ ? 0 : acc[2];
        // Limit acceleration
        float aLength = mag(ax, ay, az);
        if (aLength > swarm.maxForce) {
            float aMultiplier = swarm.maxForce / aLength;
            ax *= aMultiplier;
            ay *= aMultiplier;
            az *= aMultiplier;
        }
        vx += ax;
        vy += ay;
        vz += az;
        // Limit speed
        float vLength = mag(vx, vy, vz);
        if (vLength > swarm.maxSpeed) {
            float vMultiplier = swarm.maxSpeed / vLength;
            vx *= vMultiplier;
            vy *= vMultiplier;
            vz *= vMultiplier;
        }
        x += vx;
        y += vy;
        z += vz;
        applyBounds();
        trail.addSegment(new PVector(xPrev, yPrev, zPrev), new PVector(x, y, z));
        xPrev = x;
        yPrev = y;
        zPrev = z;
    }

    float[] steer(float[] target) {
        float steer[] = new float[3];
        float dir[] = new float[3];
        dir[0] = target[0] - x;
        dir[1] = target[1] - y;
        dir[2] = target[2] - z;
        float d = mag(dir[0], dir[1], dir[2]);
        if (d > 0) {
            float dInv = 1f / d;
            dir[0] *= dInv;
            dir[1] *= dInv;
            dir[2] *= dInv;
            // steer, desired - vel
            steer[0] = dir[0] - vx;
            steer[1] = dir[1] - vy;
            steer[2] = dir[2] - vz;
            float steerLength = mag(steer[0], steer[1], steer[2]);
            if (steerLength > 0) {
                float steerLengthInv = 1f / steerLength;
                steer[0] *= steerLengthInv;
                steer[1] *= steerLengthInv;
                steer[2] *= steerLengthInv;
            }
        }
        return steer;
    }

    float[] computeAttraction() {
        float attr[] = new float[3];
        for (AgentAttractor p : swarm.agentAttractors) {
            float dx = p.x - x;
            float dy = p.y - y;
            float dz = p.z - z;
            float dLength = mag(dx, dy, dz);
            if (dLength > 1e-7) {
                if (dLength > swarm.attractionMinRange && dLength < swarm.attractionMaxRange) {
                    float strengthNorm = swarm.attraction / dLength;
                    dx *= strengthNorm;
                    dy *= strengthNorm;
                    dz *= strengthNorm;
                    attr[0] += dx;
                    attr[1] += dy;
                    attr[2] += dz;
                }
            }
        }
        return attr;
    }

    float[] computeFlocking() {
        float[] sep = new float[3];
        float[] ali = new float[3];
        float[] coh = new float[3];
        float[] flo = new float[3];
        int countSep = 0, countAli = 0, countCoh = 0;
        float invD = 0;
        // Loop over all agents for agent/agent interaction
        for (Agent a : swarm.agents) {
            float dx = a.x - x;
            float dy = a.y - y;
            float dz = a.z - z;
            float dLength = mag(dx, dy, dz);
            if (dLength > 1e-7) {
                // If the distance is too small, ignore this agent (it is probably the same agent)
                if (dLength < swarm.separationRange) {
                    countSep++;
                    float dLengthInv = 1f / dLength;
                    sep[0] -= dx * dLengthInv;
                    sep[1] -= dy * dLengthInv;
                    sep[2] -= dz * dLengthInv;
                }
                if (dLength < swarm.cohesionRange) {
                    countCoh++;
                    coh[0] += a.x;
                    coh[1] += a.y;
                    coh[2] += a.z;
                }
                if (dLength < swarm.alignmentRange) {
                    countAli++;
                    ali[0] += a.vx;
                    ali[1] += a.vy;
                    ali[2] += a.vz;
                }
            }
        }
        if (countSep > 0) {
            float separationNorm = swarm.separation / (float) countSep;
            sep[0] *= separationNorm;
            sep[1] *= separationNorm;
            sep[2] *= separationNorm;
        }
        if (countAli > 0) {
            float alignmentNorm = swarm.alignment / (float) countAli;
            ali[0] *= alignmentNorm;
            ali[1] *= alignmentNorm;
            ali[2] *= alignmentNorm;
        }
        if (countCoh > 0) {
            float cohesionNorm = swarm.cohesion / (float) countCoh;
            coh[0] *= cohesionNorm;
            coh[1] *= cohesionNorm;
            coh[2] *= cohesionNorm;
            coh = steer(coh);
        }
        flo[0] = sep[0] + ali[0] + coh[0];
        flo[1] = sep[1] + ali[1] + coh[1];
        flo[2] = sep[2] + ali[2] + coh[2];
        return flo;
    }

    float[] computeAcceleration(float stepSize) {
        float[] flo = computeFlocking();
        float[] attr = computeAttraction();
        // Compute total acceleration
        float[] acc = new float[3];
        acc[0] = flo[0] + attr[0];
        acc[1] = flo[1] + attr[1];
        acc[2] = flo[2] + attr[2];
        float accLength = mag(acc[0], acc[1], acc[2]);
        if (accLength > 0) {
            float accMultiplier = stepSize / accLength;
            acc[0] *= accMultiplier;
            acc[1] *= accMultiplier;
            acc[2] *= accMultiplier;
        }
        return acc;
    }

}
