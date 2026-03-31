import rclpy
from rclpy.node import Node
from std_msgs.msg import String


class StarterTalker(Node):
    def __init__(self) -> None:
        super().__init__("anima_starter_talker")
        self._publisher = self.create_publisher(String, "anima/starter", 10)
        self._counter = 0
        self._timer = self.create_timer(1.0, self._publish)
        self.get_logger().info("ANIMA starter talker is publishing on /anima/starter")

    def _publish(self) -> None:
        message = String()
        message.data = f"ANIMA starter message {self._counter}"
        self._publisher.publish(message)
        self.get_logger().info(f"Publishing {message.data}")
        self._counter += 1


def main() -> None:
    rclpy.init()
    node = StarterTalker()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()
