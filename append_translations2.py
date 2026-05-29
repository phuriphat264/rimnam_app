# -*- coding: utf-8 -*-
import re

with open(r'e:\rimnam_app\lib\core\localization\app_translations.dart', 'r', encoding='utf-8') as f:
    content = f.read()

th_new = """
      'map_title': '🗺️ แผนที่ 6 สถานที่',
      'map_here': '📍 ที่นี่',
      'map_place_num': 'สถานที่ #',
      'map_done': '✓ สำเร็จ',
      'map_unlocked': 'ปลดล็อก',
      'map_locked': '🔒 ล็อค',
      'map_distance_mock': '📍 ~150 เมตรจากคุณ',
      'map_open_maps': 'เปิด Google Maps...',

      'completion_title': 'ภารกิจสำเร็จ!',
      'completion_desc': 'สำรวจครบทั้ง 6 สถานที่แล้ว\\nชุมชนริมน้ำจันทบูร',
      'completion_reward_at': 'รับของรางวัลที่',
      'completion_reward_place': 'ศูนย์การเรียนรู้\\nชุมชนริมน้ำจันทบูร',
      'completion_reward_note': 'จันทบุรี - แสดงหน้าจอนี้แก่เจ้าหน้าที่',
      'completion_route': 'ดูเส้นทาง',

      'profile_name': 'นักสำรวจนิรนาม',
      'profile_places_visited': 'สถานที่ที่ไปแล้ว',
      'profile_total_missions': 'ภารกิจทั้งหมด',
      'profile_stamp_book': 'สมุดสะสมตราประทับ',
      'profile_mission_name': 'ภารกิจชุมชนริมน้ำจันทบูร',
      'profile_completed_today': 'สำเร็จเมื่อ: วันนี้',
      'profile_progress': 'ความคืบหน้า: ',
      'profile_edit': 'แก้ไขข้อมูลส่วนตัว',
      'profile_notifications': 'การแจ้งเตือน',
      'profile_help': 'ศูนย์ช่วยเหลือ',
      'profile_logout': 'ออกจากระบบ',

      'settings_title': 'การตั้งค่า',
      'settings_profile': 'ข้อมูลส่วนตัว',
      'settings_language': 'เปลี่ยนภาษา',
      'settings_notifications': 'การแจ้งเตือน',
      'settings_help': 'ความช่วยเหลือ',
      'settings_logout': 'ออกจากระบบ',
"""

zh_new = """
      'map_title': '🗺️ 6大地点地图',
      'map_here': '📍 这里',
      'map_place_num': '地点 #',
      'map_done': '✓ 完成',
      'map_unlocked': '已解锁',
      'map_locked': '🔒 锁定',
      'map_distance_mock': '📍 距离您约150米',
      'map_open_maps': '正在打开 Google Maps...',

      'completion_title': '任务完成！',
      'completion_desc': '成功探索尖竹汶河畔社区的\\n所有6个地点',
      'completion_reward_at': '在以下地点领取奖励',
      'completion_reward_place': '尖竹汶河畔\\n学习中心',
      'completion_reward_note': '尖竹汶 - 向工作人员出示此屏幕',
      'completion_route': '查看路线',

      'profile_name': '匿名探索者',
      'profile_places_visited': '已访问地点',
      'profile_total_missions': '总任务',
      'profile_stamp_book': '印章收集册',
      'profile_mission_name': '尖竹汶河畔任务',
      'profile_completed_today': '完成时间：今天',
      'profile_progress': '进度：',
      'profile_edit': '编辑个人资料',
      'profile_notifications': '通知',
      'profile_help': '帮助中心',
      'profile_logout': '登出',

      'settings_title': '设置',
      'settings_profile': '个人资料',
      'settings_language': '更改语言',
      'settings_notifications': '通知',
      'settings_help': '帮助',
      'settings_logout': '登出',
"""

en_new = """
      'map_title': '🗺️ 6 Places Map',
      'map_here': '📍 Here',
      'map_place_num': 'Place #',
      'map_done': '✓ Done',
      'map_unlocked': 'Unlocked',
      'map_locked': '🔒 Locked',
      'map_distance_mock': '📍 ~150 meters away',
      'map_open_maps': 'Opening Google Maps...',

      'completion_title': 'Mission Accomplished!',
      'completion_desc': 'Successfully explored all 6 spots in\\nChanthabun Riverside Community',
      'completion_reward_at': 'Claim your reward at',
      'completion_reward_place': 'Chanthabun Riverside\\nLearning Center',
      'completion_reward_note': 'Chanthaburi - Show this screen to the staff',
      'completion_route': 'Get Directions',

      'profile_name': 'Anonymous Explorer',
      'profile_places_visited': 'Places Visited',
      'profile_total_missions': 'Total Missions',
      'profile_stamp_book': 'Stamp Book',
      'profile_mission_name': 'Chanthabun Riverside Mission',
      'profile_completed_today': 'Completed: Today',
      'profile_progress': 'Progress: ',
      'profile_edit': 'Edit Profile',
      'profile_notifications': 'Notifications',
      'profile_help': 'Help Center',
      'profile_logout': 'Logout',

      'settings_title': 'Settings',
      'settings_profile': 'Personal Info',
      'settings_language': 'Change Language',
      'settings_notifications': 'Notifications',
      'settings_help': 'Help',
      'settings_logout': 'Logout',
"""

content = content.replace("'tap_to_view': 'แตะเพื่อดูรายละเอียด',", "'tap_to_view': 'แตะเพื่อดูรายละเอียด'," + th_new)
content = content.replace("'tap_to_view': '点击查看详情',", "'tap_to_view': '点击查看详情'," + zh_new)
content = content.replace("'tap_to_view': 'Tap to view details',", "'tap_to_view': 'Tap to view details'," + en_new)

with open(r'e:\rimnam_app\lib\core\localization\app_translations.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Done appending")
