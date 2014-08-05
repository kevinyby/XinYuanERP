//
//  NICSignatureView.m
//  SignatureViewTest
//
//

#import "NICSignatureView.h"

#define             STROKE_WIDTH_MIN 0.002   // Stroke width determined by touch velocity
#define             STROKE_WIDTH_MAX 0.010
#define       STROKE_WIDTH_SMOOTHING 0.5   // Low pass filter alpha

#define           VELOCITY_CLAMP_MIN 20
#define           VELOCITY_CLAMP_MAX 5000

#define QUADRATIC_DISTANCE_TOLERANCE 3.0   // Minimum distance to make a curve

#define             MAXIMUM_VERTECES 100000

#define             STROKELINE_WIDTH 8


static GLKVector3 StrokeColor = { 0, 0, 0 };

// Vertex structure containing 3D point and color
struct NICSignaturePoint
{
	GLKVector3		vertex;
	GLKVector3		color;
};
typedef struct NICSignaturePoint NICSignaturePoint;


// Maximum verteces in signature
static const int maxLength = MAXIMUM_VERTECES;


// Append vertex to array buffer
static inline void addVertex(uint *length, NICSignaturePoint v) {
    if ((*length) >= maxLength) {
        return;
    }
    
    GLvoid *data = glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
    memcpy(data + sizeof(NICSignaturePoint) * (*length), &v, sizeof(NICSignaturePoint));
    glUnmapBufferOES(GL_ARRAY_BUFFER);
    
    (*length)++;
}

static inline CGPoint QuadraticPointInCurve(CGPoint start, CGPoint end, CGPoint controlPoint, float percent) {
    double a = pow((1.0 - percent), 2.0);
    double b = 2.0 * percent * (1.0 - percent);
    double c = pow(percent, 2.0);
    
    return (CGPoint) {
        a * start.x + b * controlPoint.x + c * end.x,
        a * start.y + b * controlPoint.y + c * end.y
    };
}

//static float generateRandom(float from, float to) { return random() % 10000 / 10000.0 * (to - from) + from; }
//static float clamp(min, max, value) { return fmaxf(min, fminf(max, value)); }


// Find perpendicular vector from two other vectors to compute triangle strip around line
static GLKVector3 perpendicular(NICSignaturePoint p1, NICSignaturePoint p2) {
    GLKVector3 ret;
    ret.x = p2.vertex.y - p1.vertex.y;
    ret.y = -1 * (p2.vertex.x - p1.vertex.x);
    ret.z = 0;
    return ret;
}

static NICSignaturePoint ViewPointToGL(CGPoint viewPoint, CGRect bounds, GLKVector3 color) {

    return (NICSignaturePoint) {
        {
            (viewPoint.x / bounds.size.width * 2.0 - 1),
            ((viewPoint.y / bounds.size.height) * 2.0 - 1) * -1,
            0
        },
        color
    };
}


@interface NICSignatureView () {
    // OpenGL state
    EAGLContext *context;
    GLKBaseEffect *effect;
    
    GLuint vertexArray;
    GLuint vertexBuffer;
    GLuint dotsArray;
    GLuint dotsBuffer;
    
    
    // Array of verteces, with current length
    NICSignaturePoint SignatureVertexData[maxLength];
    uint length;
    
    NICSignaturePoint SignatureDotsData[maxLength];
    uint dotsLength;
    
    
    // Width of line at current and previous vertex
    float penThickness;
    float previousThickness;
    
    
    // Previous points for quadratic bezier computations
    CGPoint previousPoint;
    CGPoint previousMidPoint;
    NICSignaturePoint previousVertex;
    NICSignaturePoint currentVelocity;
}

@end


@implementation NICSignatureView


- (void)commonInit {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (context) {
        time(NULL);
        
        self.context = context;
        self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
		self.enableSetNeedsDisplay = YES;
        
        // Turn on antialiasing
        self.drawableMultisample = GLKViewDrawableMultisample4X;
        
        [self setupGL];

        self.color = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f); // isaacs modified
        
    } else [NSException raise:@"NSOpenGLES2ContextException" format:@"Failed to create OpenGL ES2 context"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) [self commonInit];
    return self;
}


- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)ctx
{
    if (self = [super initWithFrame:frame context:ctx]) [self commonInit];
    return self;
}

-(id)init
{
    if (self = [super init]) {
        [self commonInit];
    }
    return self;
}


- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
	context = nil;
}


- (void)drawRect:(CGRect)rect
{
    if (self.hasGenie) {
        return;
    }

    glClearColor(self.color.r, self.color.g,self.color.b, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    [effect prepareToDraw];
    
    // Drawing of signature lines
    if (length > 2) {
        glBindVertexArrayOES(vertexArray);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, length);
    }

    if (dotsLength > 0) {
        glBindVertexArrayOES(dotsArray);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, dotsLength);
    }

}


- (void)erase {
    length = 0;
    dotsLength = 0;
    self.hasSignature = NO;
	
	[self setNeedsDisplay];
}



- (UIImage *)signatureImage
{
	if (!self.hasSignature)
		return nil;
    
    return [self snapshot];
}


#pragma mark - Private

- (void)bindShaderAttributes {
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(NICSignaturePoint), 0);
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 3, GL_FLOAT, GL_FALSE,  6 * sizeof(GLfloat), (char *)12);
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:context];
    
    effect = [[GLKBaseEffect alloc] init];
    
    glDisable(GL_DEPTH_TEST);
    
    // Signature Lines
    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);
    
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SignatureVertexData), SignatureVertexData, GL_DYNAMIC_DRAW);
    [self bindShaderAttributes];
    
    
    // Signature Dots
    glGenVertexArraysOES(1, &dotsArray);
    glBindVertexArrayOES(dotsArray);
    
    glGenBuffers(1, &dotsBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, dotsBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SignatureDotsData), SignatureDotsData, GL_DYNAMIC_DRAW);
    [self bindShaderAttributes];
    
    
    glBindVertexArrayOES(0);


    // Perspective
    GLKMatrix4 ortho = GLKMatrix4MakeOrtho(-1, 1, -1, 1, 0.1f, 2.0f);
    effect.transform.projectionMatrix = ortho;
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.0f);
    effect.transform.modelviewMatrix = modelViewMatrix;
    
    length = 0;
    penThickness = 0.020;
    previousPoint = CGPointMake(-100, -100);
}



- (void)addTriangleStripPointsForPrevious:(NICSignaturePoint)previous next:(NICSignaturePoint)next {
    float toTravel = penThickness / 2.0;
    
    for (int i = 0; i < 2; i++) {
        GLKVector3 p = perpendicular(previous, next);
        GLKVector3 p1 = next.vertex;
        GLKVector3 ref = GLKVector3Add(p1, p);
        
        float distance = GLKVector3Distance(p1, ref);
        float difX = p1.x - ref.x;
        float difY = p1.y - ref.y;
        float ratio = -1.0 * (toTravel / distance);
        
        difX = difX * ratio;
        difY = difY * ratio;
                
        NICSignaturePoint stripPoint = {
            { p1.x + difX, p1.y + difY, 0.0 },
            StrokeColor
        };
        addVertex(&length, stripPoint);
        
        toTravel *= -1;
    }
}


- (void)tearDownGL
{
    [EAGLContext setCurrentContext:context];
    
    glDeleteBuffers(1, &vertexBuffer);
    glDeleteVertexArraysOES(1, &vertexArray);
    
    effect = nil;
}


#pragma mark -
#pragma mark - Touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    UITouch *touch =  [touches anyObject];
    CGPoint l=[touch locationInView:self];
    
//    NSLog(@"touchesBegan l === %f,%f",l.x , l.y);
    
    previousPoint = l;
    previousMidPoint = l;
    
    NICSignaturePoint startPoint = ViewPointToGL(l, self.bounds, (GLKVector3){1, 1, 1});
    previousVertex = startPoint;
    previousThickness = penThickness;
    
    addVertex(&length, startPoint);
    addVertex(&length, previousVertex);
    
    self.hasSignature = YES;
    [self setNeedsDisplay];
    
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch* touch=[touches anyObject];
	CGPoint l=[touch locationInView:self];
    
//    NSLog(@"touchesMoved l === %f,%f",l.x , l.y);
    
    float distance = 0.;
    if (previousPoint.x > 0) {
        distance = sqrtf((l.x - previousPoint.x) * (l.x - previousPoint.x) + (l.y - previousPoint.y) * (l.y - previousPoint.y));
    }
    
    CGPoint mid = CGPointMake((l.x + previousPoint.x) / 2.0, (l.y + previousPoint.y) / 2.0);
    
    if (distance > QUADRATIC_DISTANCE_TOLERANCE) {
        
//        NSLog(@" quadratic distance === %f",distance);
        // Plot quadratic bezier instead of line
        unsigned int i;
        
        int segments = (int) distance ;
        
        float startPenThickness = previousThickness;
        float endPenThickness = penThickness;
        previousThickness = penThickness;
        
        for (i = 0; i < segments; i++)
        {
            penThickness = startPenThickness + ((endPenThickness - startPenThickness) / segments) * i;
            
            CGPoint quadPoint = QuadraticPointInCurve(previousMidPoint, mid, previousPoint, (float)i / (float)(segments));
            
            NICSignaturePoint v = ViewPointToGL(quadPoint, self.bounds, StrokeColor);
            [self addTriangleStripPointsForPrevious:previousVertex next:v];
            
            previousVertex = v;
        }
    }
    else if (distance > 1.0) {
//        NSLog(@" line distance === %f",distance);
        
        NICSignaturePoint v = ViewPointToGL(l, self.bounds, StrokeColor);
        [self addTriangleStripPointsForPrevious:previousVertex next:v];
        
        previousVertex = v;
        previousThickness = penThickness;
    }
    
    previousPoint = l;
    previousMidPoint = mid;
    [self setNeedsDisplay];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch=[touches anyObject];
	CGPoint l=[touch locationInView:self];
    
//    NSLog(@"touchesEnded ==== %f,%f",l.x , l.y);
    
    if (touch.tapCount == 1) {
        [self drawLinePoint:l];
    }else{
        NICSignaturePoint endv = ViewPointToGL(l, self.bounds, (GLKVector3){1, 1, 1});
        addVertex(&length, endv);
        previousVertex = endv;
        addVertex(&length, previousVertex);
        [self setNeedsDisplay];
    }
}

-(void)drawLinePoint:(CGPoint)l
{
    CGPoint nextPoint = l;
    nextPoint.x += STROKELINE_WIDTH;
    nextPoint.y += STROKELINE_WIDTH;
    
    
    CGPoint mid = CGPointMake((nextPoint.x + previousPoint.x) / 2.0, (nextPoint.y + previousPoint.y) / 2.0);
    
    // Plot quadratic bezier instead of line
    unsigned int i;
    int segments = 100;
    
    float startPenThickness = previousThickness;
    float endPenThickness = penThickness;
    previousThickness = penThickness;
    
    for (i = 0; i < segments; i++)
    {
        penThickness = startPenThickness + ((endPenThickness - startPenThickness) / segments) * i;
        
        CGPoint quadPoint = QuadraticPointInCurve(previousMidPoint, mid, previousPoint, (float)i / (float)(segments));
        
        NICSignaturePoint v = ViewPointToGL(quadPoint, self.bounds, StrokeColor);
        [self addTriangleStripPointsForPrevious:previousVertex next:v];
        
        previousVertex = v;
    }
    
    previousPoint = nextPoint;
    previousMidPoint = mid;
    
    NICSignaturePoint endv = ViewPointToGL(nextPoint, self.bounds, (GLKVector3){1, 1, 1});
    addVertex(&length, endv);
    previousVertex = endv;
    addVertex(&length, previousVertex);
    
    [self setNeedsDisplay];
}

@end
