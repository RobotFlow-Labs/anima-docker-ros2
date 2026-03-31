import os

import rclpy
from rclpy.node import Node


class HelloAnimaNode(Node):
    def __init__(self) -> None:
        super().__init__("hello_anima")
        distro = os.environ.get("ROS_DISTRO", "unknown")
        self.get_logger().info(
            f"RobotFlowLabs ANIMA demo node started on ROS 2 {distro}."
        )
        self.get_logger().info(
            "Your workspace is ready. Add packages under /workspaces/anima/src."
        )
        self._timer = self.create_timer(5.0, self._heartbeat)

    def _heartbeat(self) -> None:
        self.get_logger().info("ANIMA heartbeat: build, iterate, and ship.")


def main() -> None:
    rclpy.init()
    node = HelloAnimaNode()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()
