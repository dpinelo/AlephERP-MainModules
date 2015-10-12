<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>Form</class>
 <widget class="QWidget" name="Form">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>683</width>
    <height>59</height>
   </rect>
  </property>
  <property name="windowTitle">
   <string>Form</string>
  </property>
  <layout class="QVBoxLayout" name="verticalLayout">
   <property name="leftMargin">
    <number>0</number>
   </property>
   <property name="topMargin">
    <number>0</number>
   </property>
   <property name="rightMargin">
    <number>0</number>
   </property>
   <property name="bottomMargin">
    <number>0</number>
   </property>
   <item>
    <widget class="QGroupBox" name="groupBox">
     <property name="title">
      <string/>
     </property>
     <layout class="QHBoxLayout" name="horizontalLayout">
      <item>
       <widget class="QLabel" name="label">
        <property name="text">
         <string>Concepto</string>
        </property>
        <property name="buddy">
         <cstring>db_concepto</cstring>
        </property>
       </widget>
      </item>
      <item>
       <widget class="DBLineEdit" name="db_concepto">
        <property name="fieldName">
         <string>concepto</string>
        </property>
        <property name="dataEditable">
         <bool>true</bool>
        </property>
       </widget>
      </item>
     </layout>
    </widget>
   </item>
  </layout>
 </widget>
 <customwidgets>
  <customwidget>
   <class>DBLineEdit</class>
   <extends>QLineEdit</extends>
   <header>widgets/dblineedit.h</header>
  </customwidget>
 </customwidgets>
 <resources/>
 <connections/>
</ui>
