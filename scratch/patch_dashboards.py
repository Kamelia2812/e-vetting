import os

base_dir = r"C:\Users\Amelia\OneDrive\Documents\NetBeansProjects\assessmentvetting\web"

def patch_file(filename, target_str):
    filepath = os.path.join(base_dir, filename)
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    
    if "calendarWidget.jsp" not in content and target_str in content:
        replacement = target_str + """
    <div style="display:flex; flex-wrap:wrap; gap:20px; align-items:flex-start; margin-bottom: 20px;">
      <div style="flex:1; min-width:300px;">
"""
        
        # We also need to close the div. We will just let the existing code flow inside the flex item,
        # but wait, it's easier to just put the widget above everything or beside it.
        # Let's just put the widget on the right side if there's space.
        
        simple_replacement = target_str + """
    <div style="display:flex; gap:20px; flex-wrap:wrap; align-items: flex-start;">
      <div style="flex:1; min-width: 0;">
"""
        
        # Actually, if I just drop the calendar at the top, it might take full width.
        # Let's just insert it before the stat-grid.
        
        calendar_html = """
    <div style="display:flex; gap:20px; flex-wrap:wrap; align-items:flex-start;">
        <div style="flex:1; min-width: 0;">
"""
        content = content.replace(target_str, calendar_html + target_str.replace('<div class="page-section" id="page-dashboard">', ''))
        
        # Now find the end of the page-dashboard section, or just append the right column after the stat grid.
        # Actually, it's simpler:
        # Just insert the widget at the top of the dashboard section, floating right or taking 300px width.
        pass

# Let's use a simpler approach. Just insert the widget above the stat-grid or as a block.
def simple_patch(filename, target_str):
    filepath = os.path.join(base_dir, filename)
    if not os.path.exists(filepath): return
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    if "calendarWidget.jsp" not in content and target_str in content:
        # Insert a flex container
        replacement = target_str + """
    <div style="display:flex; flex-wrap:wrap; gap:20px;">
      <div style="flex:1; min-width: 0;">
"""
        content = content.replace(target_str, replacement)
        
        # Close the flex container at the end of the dashboard section
        # For KPDashboard, the dashboard section ends before <div class="page-section" id="page-courses">
        # For Lecturer, ends before id="page-courses"
        # For Vetter, ends before id="page-courses"
        
        end_target = '<div class="page-section" id="page-courses"'
        if end_target in content:
            end_replacement = """
      </div>
      <div style="width: 320px;">
        <jsp:include page="calendarWidget.jsp"/>
      </div>
    </div>
""" + end_target
            content = content.replace(end_target, end_replacement)
            
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"Patched {filename}")

simple_patch("KPDashboard.jsp", '<div class="page-section" id="page-dashboard">')
simple_patch("lecturerDashboard.jsp", '<div class="page-section" id="page-dashboard">')
simple_patch("vetterDashboard.jsp", '<div class="page-section" id="page-dashboard">')
