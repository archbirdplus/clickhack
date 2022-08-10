// jshint asi: true
// jshint esnext: true

noSmooth()
// sm64
function approach(a, target, by) {
    if(a > target) { return max(target, a-by) }
    else { return min(target, a+by) }
}

// HitBox {
function HitBox(x, y, w, h, px, py) {
    this.x = x
    this.y = y
    this.px = px === undefined ? x : px
    this.py = py === undefined ? y : py
    this.w = w
    this.h = h
}
HitBox.prototype.collide = function(b) {
    let x = b.x
    let y = b.y
    let px = b.px
    let py = b.py
    let w = b.w
    let h = b.h
    var c = { x: undefined, y: undefined, canJump: false }
    let left = b.x - b.px < this.x - this.px
    let up = b.y - b.py < this.y - this.py
    let collide = (x < this.x + this.w && x + w > this.x) && (y < this.y + this.h && y + h > this.y)
    let pXcollide = (px < this.px + this.w && px + w > this.px)
    let pYcollide = (py < this.py + this.h && py + h > this.py)
    if(collide) {
        if(!pXcollide) {
            if(left) {
                c.x = this.x + this.w
            } else {
                c.x = this.x - b.w
            }
        }
        if(!pYcollide) {
            if(up) {
                c.y = this.y + this.h
            } else {
                c.y = this.y - b.h
                c.canJump = true
            }
        }
    }
    return c
}
HitBox.prototype.draw = function() {
    fill(148, 148, 148)
    stroke(0)
    strokeWeight(1)
    rect(this.x, this.y, this.w, this.h)
}
// }

// Monster {
function Monster(x, y, w, h) {
    this.x = x
    this.y = y
    this.px = x
    this.py = y
    this.w = 20
    this.h = 20
    this.vx = 0
    this.vy = 0
    this.canJump = false
    this.goingX = 0
    this.pGoingX = 1
}
Monster.prototype.hitBox = function() {
    return new HitBox(this.x, this.y, this.w, this.h, this.px, this.py)
}
Monster.prototype.update = function() {
    this.px = this.x
    this.py = this.y
    this.vy += 0.2
    this.x += this.vx
    this.y += this.vy
    this.canJump = false
    this.pGoingX = this.goingX === 0 ? this.pGoingX : this.goingX
}
Monster.prototype.push = function(c) {
    if(c.x !== undefined) {
        let force = abs(this.vx)
        this.vy = approach(this.vy, 0, force*0.1)
        this.x = c.x
        this.vx = 0
    }
    if(c.y !== undefined) {
        let force = abs(this.vy)
        this.vx = approach(this.vx, 0, force*(this.goingX === 0 ? 0.2 : 0.1))
        this.y = c.y
        this.vy = 0
    }
    if(c.canJump) { this.canJump = true }
}
Monster.prototype.left = function() { this.vx -= 0.1; this.goingX -= 1 }
Monster.prototype.right = function() { this.vx += 0.1; this.goingX += 1 }
Monster.prototype.jump = function() {
    if(this.canJump) {
        this.canJump = false
        this.vy = -5
    }
}
Monster.prototype.draw = function() {
    stroke(37, 181, 27)
    fill(13, 219, 13)
    rect(this.x, this.y, this.w, this.h)
    fill(0)
    ellipse(this.x + (this.pGoingX*0.3 + 0.5)*(this.w), this.y + 0.3*this.w, 5, 5)
}
// }

// Bat {
function Bat(x, y) { Monster.call(this, x, y) }
Bat.prototype = Object.create(Monster.prototype)
Bat.prototype.update = function(p) {
    this.px = this.x
    this.py = this.y
    var k = 0.013
    let speed = 1
    // noise is a little bit biased to lower values
    this.vx += speed*(noise(frameCount*k, 129823.3289) - noise(frameCount*k, 98.1982))
    this.vy += speed*(noise(frameCount*k, 12.2398) - 0.5)
    let diff = new PVector(p.x - this.x, p.y - this.y)
    let d = diff.mag()
    diff.normalize()
    diff.mult(0.06 * (d > 50 ? 1 : -1))
    this.vx += diff.x
    this.vy += diff.y
    this.x += this.vx
    this.y += this.vy
    this.vx *= 0.9
    this.vy *= 0.9
}
Bat.prototype.draw = function() {
    fill(219, 173, 81)
    stroke(201, 156, 84)
    rect(this.x, this.y, this.w, this.h)
    let h = this.vx
    triangle(this.x, this.y + this.h/2, this.x - 10 + h, this.y + this.h/2 - 5, this.x - 10, this.y + this.h/2 + 7)
    triangle(this.x + this.w, this.y + this.h/2, this.x + this.w + 10 + h, this.y + this.h/2 - 5, this.x + this.w + 10, this.y + this.h/2 + 7)
    fill(100, 0, 0)
    ellipse(this.x + (0.8 + constrain(h*0.1, -0.1, 0.04))*this.w, this.y + 0.3*this.w + 0.5, 4, 4)
    ellipse(this.x + (0.4 + constrain(h*0.1, -0.1, 0.1))*this.w, this.y + 0.3*this.w, 4, 4)
};
// }

// Camera {
function Camera(x, y) {
    this.x = x
    this.y = y
    this.vx = 0
    this.vy = 0
}
Camera.prototype.follow = function(p) {
    let diff = new PVector(p.x - this.x, p.y - this.y)
    diff.mult(0.1)
    this.vx += diff.x
    this.vy += diff.y
    this.x += this.vx
    this.y += this.vy
    this.vx *= 0.1
    this.vy *= 0.1
}
Camera.prototype.pushMatrix = function() {
    pushMatrix()
    translate(-this.x + 200, -this.y + 200)
}
Camera.prototype.popMatrix = function() { popMatrix() }
// }

// Terrain Gen {
function genIsland(x, y, w, h) {
    var boxes = []
    for(var i = 0; i < 20; i++) {
        let dx = random(-w/2, w/2)
        let dy = random(-h/2, h/2)
        let nw = abs(dy) + 10
        let nh = abs(dx) + 10
        let nx = dx + x - nw/2
        let ny = dy + y - nh/2
        boxes.push(new HitBox(nx, ny, nh, nw))
    }
    return boxes
}
// }

var cam = new Camera(200, 200)

var mons = [new Monster(200, 30), new Bat(300, 30)]

var world = genIsland(200, 200, 150, 150).concat(genIsland(425, 300, 200, 150))

var keys = []
draw = function() {
    background(201, 201, 201)
    mons[0].goingX = 0
    if(keys.a || keys[LEFT]) { mons[0].left() }
    if(keys.d || keys[RIGHT]) { mons[0].right() }
    if(keys.w || keys[UP]) { mons[0].jump() }
    mons.forEach(function(m) { m.update(mons[0]) })
    mons.forEach(function(m, i) {
        mons.forEach(function(n, i) {
            m.push(n.hitBox().collide(m))
        })
    })
    mons.forEach(function(m) {
        world.forEach(function(b) { m.push(b.collide(m)) })
    })
    
    cam.follow(mons[0])
    cam.pushMatrix()
    mons.forEach(function(m) { m.draw() })
    world.forEach(function(b) { b.draw() })
    cam.popMatrix()
}

keyPressed = function() {
    keys[keyCode] = true
    keys[key.toString()] = true
    if(keyCode === SHIFT) { mons[0] = new Monster(200, 30) }
}
keyReleased = function() {
    keys[keyCode] = false
    keys[key.toString()] = false
}

