import rclpy
from rclpy.node import Node
from rosgraph_msgs.msg import Clock


class SimulationClockWatcher(Node):
    def __init__(self) -> None:
        super().__init__("anima_starter_sim_clock_watcher")
        self._received_clock = False
        self.create_subscription(Clock, "/clock", self._on_clock, 10)
        self.get_logger().info("Watching /clock for the ANIMA sim starter.")

    def _on_clock(self, _: Clock) -> None:
        if self._received_clock:
            return
        self._received_clock = True
        self.get_logger().info(
            "ANIMA sim starter confirmed ROS graph activity on /clock."
        )


def main() -> None:
    rclpy.init()
    node = SimulationClockWatcher()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()
