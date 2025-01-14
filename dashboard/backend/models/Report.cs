using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

public class Report
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Id { get; set; }
    public required string UserId { get; set; }
    public int CategoryId { get; set; }
    public DateTime? CreateDate { get; set; }
    public DateTime? ReportDate { get; set; }
    public double? Latitude { get; set; }
    public double? Longitude { get; set; }
    public required List<string> Images { get; set; }
    public required string Description { get; set; }
    public int? InvolvedActorId { get; set; }
    public int? VictimActorId { get; set; }

    [ForeignKey("CategoryId")]
    public virtual required Category Category { get; set; }

    [ForeignKey("InvolvedActorId")]
    public virtual VialActor? InvolvedActor { get; set; }

    [ForeignKey("VictimActorId")]
    public virtual VialActor? VictimActor { get; set; }

}