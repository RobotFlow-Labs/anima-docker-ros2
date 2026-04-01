import math

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image, LaserScan
from std_msgs.msg import String


class SyntheticSensorPublisher(Node):
    def __init__(self) -> None:
        super().__init__("anima_synthetic_sensor_publisher")
        self._image_publisher = self.create_publisher(
            Image, "/anima/sensors/front_camera/image_raw", 10
        )
        self._scan_publisher = self.create_publisher(
            LaserScan, "/anima/sensors/front_lidar/scan", 10
        )
        self._status_publisher = self.create_publisher(
            String, "/anima/sensors/status", 10
        )
        self._frame_index = 0
        self._timer = self.create_timer(0.5, self._publish)
        self.get_logger().info(
            "ANIMA synthetic sensors starter is publishing deterministic image and laser topics."
        )

    def _publish(self) -> None:
        timestamp = self.get_clock().now().to_msg()

        image = Image()
        image.header.stamp = timestamp
        image.header.frame_id = "anima_front_camera"
        image.height = 48
        image.width = 64
        image.encoding = "rgb8"
        image.is_bigendian = 0
        image.step = image.width * 3
        buffer = bytearray(image.height * image.step)
        for y in range(image.height):
            for x in range(image.width):
                offset = (y * image.step) + (x * 3)
                buffer[offset] = (x * 4 + self._frame_index * 3) % 256
                buffer[offset + 1] = (y * 5 + 32) % 256
                buffer[offset + 2] = (self._frame_index * 17 + x + y) % 256
        image.data = bytes(buffer)
        self._image_publisher.publish(image)

        scan = LaserScan()
        scan.header.stamp = timestamp
        scan.header.frame_id = "anima_front_lidar"
        scan.angle_min = -1.57
        scan.angle_max = 1.57
        scan.angle_increment = 3.14 / 31.0
        scan.time_increment = 0.0
        scan.scan_time = 0.5
        scan.range_min = 0.2
        scan.range_max = 8.0
        scan.ranges = [
            2.0 + (0.35 * math.sin((self._frame_index * 0.2) + (index * 0.3)))
            for index in range(32)
        ]
        scan.intensities = [48.0 + (index % 8) * 4.0 for index in range(32)]
        self._scan_publisher.publish(scan)

        status = String()
        status.data = (
            f"synthetic-frame={self._frame_index} "
            f"image=/anima/sensors/front_camera/image_raw "
            f"scan=/anima/sensors/front_lidar/scan"
        )
        self._status_publisher.publish(status)

        if self._frame_index == 0:
            self.get_logger().info("Published startup sensor frame for Foxglove.")
        elif self._frame_index % 4 == 0:
            self.get_logger().info(
                f"Published deterministic sensor frame {self._frame_index}."
            )
        self._frame_index += 1


def main() -> None:
    rclpy.init()
    node = SyntheticSensorPublisher()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()
