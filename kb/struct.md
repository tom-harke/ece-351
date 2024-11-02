eg
```
typedef enum {Request, Response, Broadcast} PacketType;
typedef struct {
int ID;
PacketType Type;
int CheckSum;
byte Data[1024];
} Packet_t;
Packet_t SamplePacket;
SamplePacket.ID = 0;
SamplePacket.Type = Request;
```

# packed

```
typedef struct        { bit [7:0] r, g, b; } pixel_u_s;
typedef struct packed { bit [7:0] r, g, b; } pixel_p_s;
```
In the first, a struct object uses 3 (32-bit) words.
In the second, a struct object uses 3 bytes.

# initialization

```
pixel_p_s p1 = '{ 8'h00, 8'hFF, 8'h00 };

$display("green = %x", p1.g);
```


