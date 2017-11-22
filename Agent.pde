class Agent {

    float x, y, z, vx, vy, vz, ax, ay, az;
    boolean isContrainedZ = false;
    Swarm swarm;

    Agent() {
    }

    Agent(Swarm swarm) {
        this.swarm = swarm;
    }

    Agent setPos(float x, float y, float z) {
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }

    Agent setVel(float vx, float vy, float vz) {
        this.vx = vx;
        this.vy = vy;
        this.vz = vz;
        return this;
    }

    void draw() {
        noStroke();
        fill(0);
        ellipse(x, y, 5, 5);
    }

    void applyBounds() {
        switch (swarm.boundMode) {
            case CLAMP:
                if (x < swarm.minX) {
                    x = swarm.minX;
                    vx = -vx;
                }
                if (x > swarm.maxX) {
                    x = swarm.maxX;
                    vx = -vx;
                }
                if (y < swarm.minY) {
                    y = swarm.minY;
                    vy = -vy;
                }
                if (y > swarm.maxY) {
                    y = swarm.maxY;
                    vy = -vy;
                }
                if (z < swarm.minZ) {
                    z = swarm.minZ;
                    vz = -vz;
                }
                if (z > swarm.maxZ) {
                    z = swarm.maxZ;
                    vz = -vz;
                }
                break;
            case WRAP:
                if (x < swarm.minX) {
                    x += swarm.boundsWidth;
                }
                if (x > swarm.maxX) {
                    x -= swarm.boundsWidth;
                }
                if (y < swarm.minY) {
                    y += swarm.boundsHeight;
                }
                if (y > swarm.maxY) {
                    y -= swarm.boundsHeight;
                }
                if (z < swarm.minZ) {
                    z += swarm.boundsDepth;
                }
                if (z > swarm.maxZ) {
                    z -= swarm.boundsDepth;
                }
                break;
        }
    }

    void update(float amount) {
        float acc[] = computeAcceleration(amount);
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
            if (dLength > 1e-7 && dLength > agentAttractorMinRange && dLength < agentAttractorMaxRange
                    ) {
                float strengthNorm = p.strength / dLength;
                dx *= strengthNorm;
                dy *= strengthNorm;
                dz *= strengthNorm;
                attr[0] += dx;
                attr[1] += dy;
                attr[2] += dz;
            }
        }
        return attr;
    }

    float[] computeAcceleration(float amount) {
        float acc[] = new float[3];
        float sep[] = new float[3];
        float ali[] = new float[3];
        float coh[] = new float[3];
        float attr[] = new float[3];
        int countSep = 0, countAli = 0, countCoh = 0;
        float invD = 0;
        // Loop over all agents for agent/agent interaction
        for (Agent b : swarm.agents) {
            float dx = b.x - x;
            float dy = b.y - y;
            float dz = b.z - z;
            float dLength = mag(dx, dy, dz);
            if (dLength <= 1e-7) {
                // If the distance is too small, ignore this agent (it is probably the same agent)
                continue;
            }
            if (dLength < swarm.separationRange) {
                countSep++;
                float dLengthInv = 1f / dLength;
                sep[0] -= dx * dLengthInv;
                sep[1] -= dy * dLengthInv;
                sep[2] -= dz * dLengthInv;
            }
            if (dLength < swarm.cohesionRange) {
                countCoh++;
                coh[0] += b.x;
                coh[1] += b.y;
                coh[2] += b.z;
            }
            if (dLength < swarm.alignmentRange) {
                countAli++;
                ali[0] += b.vx;
                ali[1] += b.vy;
                ali[2] += b.vz;
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
        // Compute total attraction vector
        attr = computeAttraction();
        // Compute total acceleration
        acc[0] = sep[0] + ali[0] + coh[0] + attr[0];
        acc[1] = sep[1] + ali[1] + coh[1] + attr[1];
        acc[2] = sep[2] + ali[2] + coh[2] + attr[2];
        float accLength = mag(acc[0], acc[1], acc[2]);
        if (accLength > 0) {
            float accMultiplier = amount / accLength;
            acc[0] *= accMultiplier;
            acc[1] *= accMultiplier;
            acc[2] *= accMultiplier;
        }
        return acc;
    }

}
