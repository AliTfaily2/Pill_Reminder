
class Pill{
  String pid;
  String name;
  int totalPills;
  int dose;
  int pillsTook;
  String hour1;
  String minute1;
  String hour2;
  String minute2;
  bool option;

  Pill(this.pid,this.name, this.totalPills, this.dose,this.pillsTook,this.hour1,this.minute1,this.hour2,this.minute2,this.option);

  @override
  String toString(){
    if(option) {
      return '''
      $name
      $dose
      $hour1:$minute1
      $hour2:$minute2
      ''';
    }
    return
    '''
     $name
     $dose
     $hour1:$minute1
    ''';
  }
}