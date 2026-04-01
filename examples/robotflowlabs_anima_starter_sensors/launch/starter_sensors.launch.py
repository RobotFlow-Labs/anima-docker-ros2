from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description() -> LaunchDescription:
    return LaunchDescription(
        [
            Node(
                package="robotflowlabs_anima_starter_sensors",
                executable="synthetic_sensor_publisher",
                output="screen",
            ),
        ]
    )
