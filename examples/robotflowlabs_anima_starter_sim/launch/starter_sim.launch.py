from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, ExecuteProcess, LogInfo
from launch.conditions import IfCondition, UnlessCondition
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description() -> LaunchDescription:
    headless = LaunchConfiguration("headless")
    world = LaunchConfiguration("world")

    gui_command = [
        "source /opt/ros/$ROS_DISTRO/setup.bash && ",
        "ros2 launch ros_gz_sim gz_sim.launch.py gz_args:=\"-r ",
        world,
        "\"",
    ]
    headless_command = [
        "source /opt/ros/$ROS_DISTRO/setup.bash && ",
        "ros2 launch ros_gz_sim gz_sim.launch.py gz_args:=\"-s -r ",
        world,
        "\"",
    ]

    return LaunchDescription(
        [
            DeclareLaunchArgument("headless", default_value="false"),
            DeclareLaunchArgument("world", default_value="shapes.sdf"),
            LogInfo(
                msg="RobotFlowLabs ANIMA sim starter launching Gazebo on the noVNC desktop."
            ),
            LogInfo(msg="Bridging Gazebo clock onto /clock for ROS 2 tools."),
            ExecuteProcess(
                cmd=["bash", "-lc", gui_command],
                output="screen",
                condition=UnlessCondition(headless),
            ),
            ExecuteProcess(
                cmd=["bash", "-lc", headless_command],
                output="screen",
                condition=IfCondition(headless),
            ),
            Node(
                package="ros_gz_bridge",
                executable="parameter_bridge",
                arguments=["/clock@rosgraph_msgs/msg/Clock[gz.msgs.Clock"],
                output="screen",
            ),
            Node(
                package="robotflowlabs_anima_starter_sim",
                executable="clock_watcher",
                output="screen",
            ),
        ]
    )
