from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description() -> LaunchDescription:
    return LaunchDescription(
        [
            Node(
                package="robotflowlabs_anima_pubsub",
                executable="listener",
                output="screen",
            ),
            Node(
                package="robotflowlabs_anima_pubsub",
                executable="talker",
                output="screen",
            ),
        ]
    )
