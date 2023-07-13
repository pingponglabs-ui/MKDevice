# MKDevice
MetalKit Photo distortion tools to retouch


## Tools

###Main

public enum MainTools:String, CaseIterable{
    case manual, body, retouch, forms, filters, adjust, text, background
}

###SubTools

enum AdjustToolType:String, CaseIterable{ case brightness, contrast, saturation, shadows, highlights }

enum ManualToolType:String, CaseIterable{ case move, shrink, grow }

enum BodyToolType:String, CaseIterable{ case slim, tall, head, waist, hips }

enum RetouchToolType:String, CaseIterable{case smooth ,spot_heal, dark_circle ,details ,eye_color  ,whiten}


enum BGToolType:String, CaseIterable{case none ,red, green ,blue}



###SubSubTools
enum EyeColors:String, CaseIterable{
    case  none, eye_blue, eye_brown, eye_green, eye_purple, eye_turquoise
}
enum EyeColorToolType:String, CaseIterable{case smooth ,spot_heal, dark_circle ,details ,eye_color  ,whiten}

enum BackgroundColors:String, CaseIterable{
    case  none, red, green, blue
}





## USECASEs:

    var photoEditor : PhotoEditorTools
    var image = UIImage(named:"test_image")
    
    init(){
    
                photoEditor = PhotoEditorTools(uiimage: image)
            
            view.addSubview(photoEditor.mtlView
}


func setMainTool( mianTool:MainTools){

        photoEditor.mainTool = .retouch
    }

func setRetouchTool( retouchTool:RetouchToolType){

        photoEditor.toolRetouch = .spot_heal


}


func setToolValue(){

        photoEditor.uniforms.mouse = float2(x, y)
        photoEditor.uniforms.intensity = 0.5

}

func setImage(image: UIImage){

        photoEditor.setImage(uiimage: image)

}

@objc func resetToolValue(){

        photoEditor.resetValues()
        

}

