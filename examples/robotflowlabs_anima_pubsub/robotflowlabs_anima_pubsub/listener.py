import rclpy
from rclpy.node import Node
from std_msgs.msg import String


class StarterListener(Node):
    def __init__(self) -> None:
        super().__init__("anima_starter_listener")
        self.create_subscription(String, "anima/starter", self._on_message, 10)
        self.get_logger().info("ANIMA starter listener is waiting on /anima/starter")

    def _on_message(self, message: String) -> None:
        self.get_logger().info(f"heard {message.data}")


def main() -> None:
    rclpy.init()
    node = StarterListener()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()
